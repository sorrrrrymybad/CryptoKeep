//
//  CryptoKeepWidget.swift
//  CryptoKeepWidget
//
//  Created by developer on 2025/2/9.
//

import WidgetKit
import SwiftUI
import SwiftData

// 添加 ValueChange 结构体定义
struct ValueChange: Equatable {
    let amount: Double
    let percentage: Double
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), totalValue: 0, valueChange: ValueChange(amount: 0, percentage: 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let entry = await loadData()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            // 创建多个时间点的 entries
            var entries: [SimpleEntry] = []
            
            // 当前数据
            let currentEntry = await loadData()
            entries.append(currentEntry)
            
            // 未来的更新时间点
            let calendar = Calendar.current
            let currentDate = Date()
            
            // 创建接下来5分钟内的更新点
            for minuteOffset in stride(from: 1, through: 5, by: 1) {
                guard let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: currentDate) else {
                    continue
                }
                
                // 为每个时间点加载新数据，并使用正确的日期
                let futureEntry = SimpleEntry(
                    date: entryDate,
                    totalValue: currentEntry.totalValue,
                    valueChange: currentEntry.valueChange
                )
                entries.append(futureEntry)
            }
            
            // 设置更新策略为5分钟后重新加载
            let updateDate = calendar.date(byAdding: .minute, value: 5, to: currentDate) ?? currentDate
            let timeline = Timeline(entries: entries, policy: .after(updateDate))
            
            completion(timeline)
        }
    }
    
    private func loadData() async -> SimpleEntry {
        // 使用相同的 App Group 配置
        let config = ModelConfiguration(groupContainer: .identifier("group.sorrymybad0.CryptoKeep"))
        let modelContainer = try? ModelContainer(for: FundRecord.self, configurations: config)
        
        let records = await withCheckedContinuation { continuation in
            Task { @MainActor in
                let descriptor = FetchDescriptor<FundRecord>()
                let records = try? modelContainer?.mainContext.fetch(descriptor) ?? []
                continuation.resume(returning: records ?? [])
            }
        }
        
        // 获取价格
        let prices = try? await PriceService.shared.fetchPrices()
        
        var totalOpenValue = 0.0
        var totalCurrentValue = 0.0
        
        // 计算总值
        if let prices = prices {
            for record in records {
                if let price = prices["\(record.coinSymbol)USDT"] {
                    let currentPrice = price.price ?? 0
                    let openPrice = Double(price.open) ?? 0
                    
                    totalOpenValue += openPrice * record.amount
                    totalCurrentValue += currentPrice * record.amount
                }
            }
        }
        
        // 计算涨跌
        let changeAmount = totalCurrentValue - totalOpenValue
        let changePercentage = totalOpenValue > 0 ? (changeAmount / totalOpenValue) * 100 : 0
        
        let valueChange = ValueChange(amount: changeAmount * CurrencyConverter.usdToCNYRate, 
                                   percentage: changePercentage)
        
        return SimpleEntry(
            date: Date(),
            totalValue: totalCurrentValue * CurrencyConverter.usdToCNYRate,
            valueChange: valueChange
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalValue: Double
    let valueChange: ValueChange?
}

struct CryptoKeepWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 4) {
            Text("总资产估值")
                .font(.headline)
                .foregroundColor(Color.orange)
            Text(CurrencyConverter.formatCompactCNY(entry.totalValue))
                .font(.system(size: 28))
                .bold()
            
            if let change = entry.valueChange {
                // 涨跌金额
                Text(formatChangeAmount(change.amount))
                    .font(.caption)
                    .foregroundColor(change.amount >= 0 ? .green : .red)
                
                // 涨跌百分比
                HStack(spacing: 4) {
                    Text(formatChangePercentage(change.percentage))
                        .foregroundColor(change.percentage >= 0 ? .green : .red)
                    Text("24h")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.background, for: .widget)
    }
    
    private func formatChangeAmount(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(CurrencyConverter.formatCompactCNY(value))"
    }
    
    private func formatChangePercentage(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
}

struct CryptoKeepWidget: Widget {
    let kind: String = "CryptoKeepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 16.0, *) {
                ViewThatFits {
                    // 主屏幕 Widget
                    CryptoKeepWidgetEntryView(entry: entry)
                        .containerBackground(.background, for: .widget)
                    
                    // 锁屏 Widget
                    LockScreenWidgetView(entry: entry)
                }
            } else {
                CryptoKeepWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            }
        }
        .configurationDisplayName("加密货币资产")
        .description("显示总资产和当日涨跌")
        .supportedFamilies([.systemSmall, .accessoryRectangular])  // 添加锁屏支持
        .contentMarginsDisabled()
    }
}

// 添加锁屏 Widget 视图
@available(iOSApplicationExtension 16.0, *)
struct LockScreenWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 2) {
            Text("总资产估值")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(CurrencyConverter.formatCompactCNY(entry.totalValue))
                .font(.system(size: 24))
                .bold()
                .foregroundColor(.white)
            
            if let change = entry.valueChange {
                HStack(spacing: 4) {
                    Text(formatChangeAmount(change.amount))
                        .foregroundColor(.white)
                        .opacity(change.amount >= 0 ? 1 : 0.8)
                    
                    Text(formatChangePercentage(change.percentage))
                        .foregroundColor(.white)
                        .opacity(change.percentage >= 0 ? 1 : 0.8)
                }
                .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.clear, for: .widget)
    }
    
    private func formatChangeAmount(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(CurrencyConverter.formatCompactCNY(value))"
    }
    
    private func formatChangePercentage(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
}

#Preview(as: .systemSmall) {
    CryptoKeepWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        totalValue: 1_800_000,
        valueChange: ValueChange(amount: 12340, percentage: 1.23)
    )
}

#Preview(as: .accessoryRectangular) {
    CryptoKeepWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        totalValue: 1_800_000,
        valueChange: ValueChange(amount: 12340, percentage: 1.23)
    )
}
