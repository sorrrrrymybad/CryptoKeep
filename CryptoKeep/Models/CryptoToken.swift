import Foundation

struct CryptoToken: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let logoURL: URL
    
    static let supportedCurrencies: [CryptoToken] = [
        CryptoToken(
            name: "Bitcoin",
            symbol: "BTC",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png")!
        ),
        CryptoToken(
            name: "Ethereum",
            symbol: "ETH",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/279/large/ethereum.png")!
        ),
        CryptoToken(
            name: "BNB",
            symbol: "BNB",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png")!
        ),
        CryptoToken(
            name: "XRP",
            symbol: "XRP",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png")!
        ),
        CryptoToken(
            name: "Solana",
            symbol: "SOL",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/4128/large/solana.png")!
        ),
        CryptoToken(
            name: "Cardano",
            symbol: "ADA",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/975/large/cardano.png")!
        ),
        CryptoToken(
            name: "Dogecoin",
            symbol: "DOGE",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/5/large/dogecoin.png")!
        ),
        CryptoToken(
            name: "Polkadot",
            symbol: "DOT",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/12171/large/polkadot.png")!
        ),
        CryptoToken(
            name: "TRON",
            symbol: "TRX",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/1094/large/tron-logo.png")!
        ),
        CryptoToken(
            name: "Polygon",
            symbol: "MATIC",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/4713/large/matic-token-icon.png")!
        ),
        CryptoToken(
            name: "Litecoin",
            symbol: "LTC",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/2/large/litecoin.png")!
        ),
        CryptoToken(
            name: "Chainlink",
            symbol: "LINK",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png")!
        ),
        CryptoToken(
            name: "Uniswap",
            symbol: "UNI",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/12504/large/uniswap-uni.png")!
        ),
        CryptoToken(
            name: "Bitcoin Cash",
            symbol: "BCH",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/780/large/bitcoin-cash-circle.png")!
        ),
        CryptoToken(
            name: "USD Coin",
            symbol: "USDC",
            logoURL: URL(string: "https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png")!
        ),
        CryptoToken(
            name: "NEXO",
            symbol: "NEXO",
            logoURL: URL(string: "https://dd49625.webp.li/CryptoLogos/nexo-nexo-logo-27484548fe1f0631e83694ddb109afcb.png")!
        ),
        CryptoToken(
            name: "Official Trump",
            symbol: "TRUMP",
            logoURL: URL(string: "https://dd49625.webp.li/CryptoLogos/trump-9e4b379a87870e9beba21b92cd90a589.png")!
        ),
        CryptoToken(
            name: "Melania Meme",
            symbol: "MELANIA",
            logoURL: URL(string: "https://dd49625.webp.li/CryptoLogos/melania-1501f79aefa960443a8c4e0b025822c6.jpeg")!
        )
    ]
} 
