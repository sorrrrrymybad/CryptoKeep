//
//  CryptoKeepWidgetBundle.swift
//  CryptoKeepWidget
//
//  Created by developer on 2025/2/9.
//

import WidgetKit
import SwiftUI

@main
struct CryptoKeepWidgetBundle: WidgetBundle {
    var body: some Widget {
        CryptoKeepWidget()
        CryptoKeepWidgetControl()
        CryptoKeepWidgetLiveActivity()
    }
}
