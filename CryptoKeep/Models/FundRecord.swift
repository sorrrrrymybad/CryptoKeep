//
//  Item.swift
//  CryptoKeep
//
//  Created by developer on 2025/2/5.
//

import Foundation
import SwiftData

@Model
final class FundRecord {
    var timestamp: Date
    var coinName: String
    var coinSymbol: String
    var amount: Double
    var priceInUSD: Double
    
    init(timestamp: Date, coinName: String, coinSymbol: String, amount: Double, priceInUSD: Double) {
        self.timestamp = timestamp
        self.coinName = coinName
        self.coinSymbol = coinSymbol
        self.amount = amount
        self.priceInUSD = priceInUSD
    }
    
    var valueInCNY: Double {
        return amount * priceInUSD * CurrencyConverter.usdToCNYRate
    }
}
