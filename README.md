# CryptoKeep

一个专业的加密货币资产管理应用，支持实时价格监控、资产组合管理和桌面 Widget 显示。

## 🚀 功能特性

### 核心功能

- **资产管理**: 支持添加、删除、修改多种加密货币的持有数量
- **实时价格**: 自动获取最新价格和 24 小时涨跌幅
- **多币种支持**: 内置 20+主流加密货币，包括 BTC、ETH、BNB、SOL 等
- **智能合并**: 相同币种自动合并，避免重复记录
- **自动刷新**: 每 30 秒自动更新价格，应用进入前台时立即刷新

### 界面特性

- **现代化 UI**: 使用 SwiftUI 构建，支持浅色/深色模式
- **触觉反馈**: 添加触觉震动提升交互体验
- **空状态引导**: 首次使用时显示友好的引导界面
- **响应式设计**: 适配不同屏幕尺寸

### Widget 支持

- **桌面 Widget**: 显示总资产和当日涨跌
- **锁屏 Widget**: 支持锁屏界面显示
- **实时更新**: 每 5 分钟自动刷新数据
- **数据同步**: 与主应用实时同步

## 🏗️ 技术架构

### 架构模式

- **MVVM**: 使用 Model-View-ViewModel 架构
- **SwiftData**: 本地数据持久化存储
- **App Group**: 主应用与 Widget 数据共享

### 技术栈

- **SwiftUI**: 现代化声明式 UI 框架
- **SwiftData**: iOS 17+ 数据持久化框架
- **WidgetKit**: 桌面和锁屏 Widget 支持
- **Combine**: 响应式编程和状态管理

### 项目结构

```
CryptoKeep/
├── Models/                 # 数据模型
│   ├── FundRecord.swift   # 资产记录模型
│   └── CryptoToken.swift  # 支持的加密货币列表
├── Views/                  # 视图层
│   ├── PortfolioView.swift    # 主界面
│   ├── AddCoinView.swift      # 添加币种界面
│   ├── AmountEditView.swift   # 数量编辑界面
│   ├── CachedAsyncImage.swift # 图片缓存组件
│   └── ContentView.swift      # 内容视图
├── ViewModels/            # 视图模型
│   └── PortfolioViewModel.swift # 投资组合视图模型
├── Services/              # 服务层
│   └── PriceService.swift # 价格服务
├── Resources/             # 资源文件
│   └── Utils/            # 工具类
│       ├── CurrencyConverter.swift # 货币转换工具
│       ├── ImageCache.swift       # 图片缓存管理
│       └── HapticsManager.swift   # 触觉反馈管理
└── CryptoKeepApp.swift   # 应用入口

CryptoKeepWidget/          # Widget 扩展
├── CryptoKeepWidget.swift # Widget 主视图
└── ...                    # 其他 Widget 相关文件
```

## 📱 支持的加密货币

应用内置支持以下 20+主流加密货币：

| 币种         | 符号    | 币种           | 符号  |
| ------------ | ------- | -------------- | ----- |
| Bitcoin      | BTC     | Ethereum       | ETH   |
| BNB          | BNB     | XRP            | XRP   |
| Solana       | SOL     | Cardano        | ADA   |
| Dogecoin     | DOGE    | Polkadot       | DOT   |
| TRON         | TRX     | Polygon        | MATIC |
| Litecoin     | LTC     | Chainlink      | LINK  |
| Uniswap      | UNI     | Bitcoin Cash   | BCH   |
| Tether       | USDT    | USD Coin       | USDC  |
| NEXO         | NEXO    | Official Trump | TRUMP |
| Melania Meme | MELANIA |                |       |

## 🛠️ 安装说明

### 系统要求

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### 安装步骤

1. 克隆项目到本地
2. 在 Xcode 中打开 `CryptoKeep.xcodeproj`
3. 配置开发者账号和 Bundle Identifier
4. 配置 App Group 权限
5. 构建并运行项目

### App Group 配置

确保主应用和 Widget 扩展都配置了相同的 App Group：

```
group.sorrymybad0.CryptoKeep
```

## 🔧 配置说明

### 价格 API

应用使用以下 API 获取实时价格数据：

```
https://bot.52188.online/cy
```

### 汇率设置

默认 USD 到 CNY 汇率为 7.35，可在 `CurrencyConverter.swift` 中修改。

## 📊 数据模型

### FundRecord

```swift
@Model
final class FundRecord {
    var timestamp: Date      // 记录时间
    var coinName: String     // 币种名称
    var coinSymbol: String   // 币种符号
    var amount: Double       // 持有数量
    var priceInUSD: Double   // 美元价格

    var valueInCNY: Double   // 人民币价值（计算属性）
}
```

### CryptoPrice

```swift
struct CryptoPrice: Codable {
    let symbol: String       // 交易对符号
    let lastPr: String       // 最新价格
    let change24h: String    // 24小时涨跌幅
    let open: String         // 开盘价
}
```

## 🎯 使用说明

### 添加币种

1. 点击右上角 "+" 按钮
2. 从支持的币种列表中选择
3. 输入持有数量
4. 确认添加

### 修改数量

1. 点击任意币种的数量显示
2. 在弹出的编辑框中输入新数量
3. 确认修改

### 删除币种

1. 左滑币种条目
2. 点击删除按钮
3. 或修改数量为 0 自动删除

### 查看 Widget

1. 长按桌面空白处
2. 点击左上角 "+" 按钮
3. 搜索 "CryptoKeep"
4. 选择 Widget 尺寸并添加

## 🔄 更新机制

- **价格更新**: 每 30 秒自动刷新
- **Widget 更新**: 每 5 分钟自动刷新
- **数据同步**: 主应用与 Widget 实时同步
- **缓存管理**: 自动清理过期图片缓存

## 🐛 故障排除

### Widget 不显示数据

1. 检查 App Group 配置是否一致
2. 确认主应用已添加资产
3. 重启应用和 Widget
4. 检查网络连接

### 价格不更新

1. 检查网络连接
2. 确认 API 服务正常
3. 查看控制台错误日志

## 📄 许可证

本项目仅供学习和研究使用。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进项目。

## 📞 联系方式

如有问题或建议，请通过 GitHub Issues 联系。

---

**注意**: 本应用仅用于资产管理，不构成投资建议。加密货币投资存在风险，请谨慎投资。
