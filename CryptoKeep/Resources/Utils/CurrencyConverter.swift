import Foundation

enum CurrencyConverter {
    static let usdToCNYRate: Double = 7.35
    
    static func formatCNY(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "¥0.00"
    }
    
    static func formatCompactCNY(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""
        
        if absValue >= 1_000_000 {
            return "\(sign)¥\(String(format: "%.2f", absValue / 1_000_000))M"
        } else if absValue >= 1_000 {
            return "\(sign)¥\(String(format: "%.2f", absValue / 1_000))K"
        } else {
            return formatCNY(value)
        }
    }
} 