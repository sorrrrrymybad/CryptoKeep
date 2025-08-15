import Foundation

struct CryptoPrice: Codable {
    let symbol: String
    let lastPr: String
    let change24h: String
    let open: String  // 添加开盘价
    
    var price: Double? {
        Double(lastPr)
    }
    
    var priceChange: Double? {
        if let change = Double(change24h) {
            return change * 100 // 转换为百分比
        }
        return nil
    }
    
    var openPrice: Double? {
        Double(open)
    }
}

struct PriceResponse: Codable {
    let code: String
    let data: [CryptoPrice]
}

actor PriceService {
    static let shared = PriceService()
    private let apiURL = URL(string: "")!
    private let fxURL = URL(string: "")!
    
    private init() {}
    
    func fetchPrices() async throws -> [String: CryptoPrice] {
        let (data, _) = try await URLSession.shared.data(from: apiURL)
        let response = try JSONDecoder().decode(PriceResponse.self, from: data)
        
        // 将数组转换为字典，方便查询
        return Dictionary(uniqueKeysWithValues: response.data.map { ($0.symbol, $0) })
    }

    private struct FxEnvelope: Codable {
        let code: String
        let data: [FxItem]
        let success: Bool
    }
    private struct FxItem: Codable {
        let asset: String
        let currency: String
        let referencePrice: Double
    }

    /// 获取 USDT->CNY 参考价
    func fetchUsdToCnyRate() async throws -> Double {
        let (data, _) = try await URLSession.shared.data(from: fxURL)
        let env = try JSONDecoder().decode(FxEnvelope.self, from: data)
        if let item = env.data.first(where: { $0.asset.uppercased() == "USDT" && $0.currency.uppercased() == "CNY" }) {
            return item.referencePrice
        }
        throw NSError(domain: "PriceService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Rate not found"])
    }
} 
