//
//  ContentView.swift
//  CryptoKeep
//
//  Created by developer on 2025/2/5.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: .init(
            get: {
                selectedTab
            },
            set: { newTab in
                selectedTab = newTab
                HapticsManager.shared.play(.light)
            }
        )) {
            NavigationStack {
                Text("统计").navigationTitle("统计")
            }.tabItem {
                Image(systemName: "tennis.racket")
                Text("实况")
            }.badge(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            NavigationStack {
                Text("统计").navigationTitle("统计")
            }.tabItem {
                Image(systemName: "chart.bar.xaxis")
                Text("统计")
            }
            NavigationStack {
                Text("成就").navigationTitle("成就")
            }.tabItem {
                Image(systemName: "medal.fill")
                Text("成就")
            }
        }
    }
}

#Preview {
    ContentView()
}
