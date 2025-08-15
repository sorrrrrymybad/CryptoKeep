//
//  HapticsManager.swift
//  CryptoKeep
//
//  Created by developer on 2024/8/19.
//

import CoreHaptics
import SwiftUI

class HapticsManager {
    static let shared = HapticsManager()
    private var engine: CHHapticEngine?

    private init() {
        #if targetEnvironment(simulator)
        print("Running on Simulator")
        #else
            createHapticEngine()
        #endif
    }

    private func createHapticEngine() {
        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                self?.createHapticEngine()
            }
        } catch {
            print("Failed to create haptic engine: \(error.localizedDescription)")
        }
    }

//    自定义震动
    func playCustom(fromResource resource: String, withExtension fileExtension: String = "json") {
        guard let engine = engine else {
            print("Haptic engine is not available")
            return
        }

        guard let url = Bundle.main.url(forResource: resource, withExtension: fileExtension) else {
            print("Failed to find resource: \(resource).\(fileExtension)")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            try engine.playPattern(from: data)
        } catch {
            print("Failed to load or play haptics: \(error.localizedDescription)")
        }
    }

    // 播放UIImpactFeedbackGenerator的触觉反馈 (iOS)
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        generator.prepare() // 预加载触觉反馈
        generator.impactOccurred()
//        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }

    // 播放UINotificationFeedbackGenerator的通知震动 (iOS)
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare() // 预加载通知震动
        generator.notificationOccurred(feedbackType)
//        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
