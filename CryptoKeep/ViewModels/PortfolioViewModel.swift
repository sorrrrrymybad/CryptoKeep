import SwiftUI
import SwiftData
import WidgetKit

class PortfolioViewModel: ObservableObject {
    private var modelContext: ModelContext
    @Published var fundRecords: [FundRecord] = []
    @Published var totalValueChange: ValueChange?
    private var priceChanges: [String: Double] = [:]  // 存储每个币种的涨跌幅
    
    var totalValueInCNY: Double {
        fundRecords.reduce(0) { $0 + $1.valueInCNY }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchItems()
    }
    
    func fetchItems() {
        let descriptor = FetchDescriptor<FundRecord>(sortBy: [SortDescriptor(\.coinName)])
        fundRecords = (try? modelContext.fetch(descriptor)) ?? []
        // 通知视图更新总价值
        objectWillChange.send()
    }
    
    private func refreshWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    @MainActor
    func addItem(coinName: String, coinSymbol: String, amount: Double, priceInUSD: Double = 0) async {
        // 先获取最新价格
        do {
            let prices = try await PriceService.shared.fetchPrices()
            let currentPrice = prices["\(coinSymbol)USDT"]?.price ?? 0
            
            // 检查是否已存在相同币种的记录
            if let existingRecord = fundRecords.first(where: { $0.coinSymbol == coinSymbol }) {
                // 更新现有记录
                existingRecord.amount += amount
                existingRecord.priceInUSD = currentPrice
                existingRecord.timestamp = Date()
            } else {
                // 创建新记录
                let fundRecord = FundRecord(
                    timestamp: Date(),
                    coinName: coinName,
                    coinSymbol: coinSymbol,
                    amount: amount,
                    priceInUSD: currentPrice
                )
                modelContext.insert(fundRecord)
            }
            
            try? modelContext.save()
            fetchItems()
            refreshWidget()
        } catch {
            print("Error fetching price when adding item: \(error)")
        }
    }
    
    func deleteItem(_ fundRecord: FundRecord) {
        modelContext.delete(fundRecord)
        try? modelContext.save()
        fetchItems()
        refreshWidget()
    }
    
    // 新增：更新币种数量
    func updateAmount(for fundRecord: FundRecord, newAmount: Double) {
        if newAmount <= 0 {
            // 如果数量为0或负数，删除记录
            deleteItem(fundRecord)
        } else {
            fundRecord.amount = newAmount
            try? modelContext.save()
            fetchItems()
            refreshWidget()
        }
    }
    
    func getPriceChange(for symbol: String) -> Double? {
        return priceChanges[symbol]
    }
    
    @MainActor
    func refreshPrices() async throws {
        let prices = try await PriceService.shared.fetchPrices()
        var totalOpenValue = 0.0
        var totalCurrentValue = 0.0
        
        for record in fundRecords {
            if let price = prices["\(record.coinSymbol)USDT"] {
                let currentPrice = price.price ?? 0
                let openPrice = Double(price.open) ?? 0
                
                record.priceInUSD = currentPrice
                priceChanges[record.coinSymbol] = price.priceChange  // 保存涨跌幅
                
                // 计算开盘和当前总值
                totalOpenValue += openPrice * record.amount
                totalCurrentValue += currentPrice * record.amount
            }
        }
        
        // 计算涨跌值和百分比
        let changeAmount = totalCurrentValue - totalOpenValue
        let changePercentage = totalOpenValue > 0 ? (changeAmount / totalOpenValue) * 100 : 0
        
        totalValueChange = ValueChange(amount: changeAmount * CurrencyConverter.usdToCNYRate, percentage: changePercentage)
        objectWillChange.send()
        refreshWidget()
    }
} 
