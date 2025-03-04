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
            let config = ModelConfiguration(groupContainer: .identifier("group.CY-7F74EF40-E3DD-11E6-B1BC-ABE53572EED3.com.baidu.netdisk.share"))
            container = try ModelContainer(for: FundRecord.self, configurations: config)
            
            // 应用启动时清理过期缓存
            Task {
                await ImageCache.shared.clearExpiredCache()
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
