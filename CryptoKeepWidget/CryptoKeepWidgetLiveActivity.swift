//
//  CryptoKeepWidgetLiveActivity.swift
//  CryptoKeepWidget
//
//  Created by developer on 2025/2/9.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CryptoKeepWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CryptoKeepWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CryptoKeepWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CryptoKeepWidgetAttributes {
    fileprivate static var preview: CryptoKeepWidgetAttributes {
        CryptoKeepWidgetAttributes(name: "World")
    }
}

extension CryptoKeepWidgetAttributes.ContentState {
    fileprivate static var smiley: CryptoKeepWidgetAttributes.ContentState {
        CryptoKeepWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CryptoKeepWidgetAttributes.ContentState {
         CryptoKeepWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CryptoKeepWidgetAttributes.preview) {
   CryptoKeepWidgetLiveActivity()
} contentStates: {
    CryptoKeepWidgetAttributes.ContentState.smiley
    CryptoKeepWidgetAttributes.ContentState.starEyes
}
