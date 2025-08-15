import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    private var memoryCache: [URL: Image] = [:]
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // 在初始化时确定缓存目录
        let baseDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = baseDirectory.appendingPathComponent("ImageCache")
        
        // 创建缓存目录
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory,
                                                  withIntermediateDirectories: true)
        }
    }
    
    private func cacheFileURL(for url: URL) -> URL {
        cacheDirectory.appendingPathComponent(url.lastPathComponent)
    }
    
    func image(for url: URL) -> Image? {
        // 先检查内存缓存
        if let cachedImage = memoryCache[url] {
            return cachedImage
        }
        
        // 检查磁盘缓存
        let fileURL = cacheFileURL(for: url)
        guard let data = try? Data(contentsOf: fileURL),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        
        let image = Image(uiImage: uiImage)
        // 加入内存缓存
        memoryCache[url] = image
        return image
    }
    
    func insert(_ image: Image, for url: URL) async {
        // 保存到内存缓存
        memoryCache[url] = image
        
        // 在主线程上转换图片
        guard let uiImage = await MainActor.run(body: {
            image.asUIImage()
        }) else { return }
        
        // 保存到磁盘缓存
        let fileURL = cacheFileURL(for: url)
        guard let data = uiImage.pngData() else { return }
        
        try? data.write(to: fileURL)
    }
    
    func clear() {
        // 清除内存缓存
        memoryCache.removeAll()
        
        // 清除磁盘缓存
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory,
                                      withIntermediateDirectories: true)
    }
    
    // 清除过期缓存（可以定期调用）
    func clearExpiredCache(olderThan days: Int = 7) {
        let expirationDate = Date().addingTimeInterval(-Double(days * 24 * 60 * 60))
        
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        ) else { return }
        
        for fileURL in fileURLs {
            guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                  let creationDate = attributes[.creationDate] as? Date,
                  creationDate < expirationDate else {
                continue
            }
            try? fileManager.removeItem(at: fileURL)
        }
    }
}

// 扩展 Image 以支持转换为 UIImage
extension Image {
    @MainActor
    func asUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage
    }
}

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var isLoading = false
    private var url: URL
    private var task: Task<Void, Never>?
    
    init(url: URL) {
        self.url = url
    }
    
    func load() {
        guard image == nil else { return }
        
        task = Task {
            // 首先检查缓存
            if let cached = await ImageCache.shared.image(for: url) {
                image = cached
                return
            }
            
            isLoading = true
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let uiImage = UIImage(data: data) else { return }
                let image = Image(uiImage: uiImage)
                // 保存到缓存
                await ImageCache.shared.insert(image, for: url)
                self.image = image
            } catch {
                print("Error loading image: \(error)")
            }
            isLoading = false
        }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
    
    deinit {
        // 直接取消任务，不使用 cancel() 方法
        task?.cancel()
    }
} 
