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
    private let apiURL = URL(string: "https://api.bitget.com/api/v2/spot/market/tickers")!
    
    private init() {}
    
    func fetchPrices() async throws -> [String: CryptoPrice] {
        let (data, _) = try await URLSession.shared.data(from: apiURL)
        let response = try JSONDecoder().decode(PriceResponse.self, from: data)
        
        // 将数组转换为字典，方便查询
        return Dictionary(uniqueKeysWithValues: response.data.map { ($0.symbol, $0) })
    }
} 