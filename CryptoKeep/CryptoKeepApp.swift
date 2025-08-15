//
//  CryptoKeepApp.swift
//  CryptoKeep
//
//  Created by developer on 2025/2/5.
//

import SwiftUI
import SwiftData
import WidgetKit

@main
struct CryptoKeepApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(groupContainer: .identifier("group.sorrymybad0.CryptoKeep"))
            container = try ModelContainer(for: FundRecord.self, configurations: config)
            
            // 应用启动时清理过期缓存
            Task {
                await ImageCache.shared.clearExpiredCache()
                // 刷新汇率
                if let rate = try? await PriceService.shared.fetchUsdToCnyRate() {
                    CurrencyConverter.usdToCNYRate = rate
                }
                WidgetCenter.shared.reloadAllTimelines()  // 应用启动时刷新 Widget
            }
        } catch {
            fatalError("无法创建 ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            // 将 PortfolioView 设置为主视图
            PortfolioView(modelContext: container.mainContext)
        }
        // 将 ModelContainer 注入到环境中
        .modelContainer(container)
    }
}
