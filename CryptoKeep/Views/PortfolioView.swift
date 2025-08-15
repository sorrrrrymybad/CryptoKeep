import SwiftUI
import SwiftData

struct PortfolioView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PortfolioViewModel
    @State private var showingAddSheet = false
    @Query(sort: \FundRecord.coinName) var fundRecords: [FundRecord]
    
    // 添加定时器状态
    @State private var timer: Timer?
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: PortfolioViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 总资产价值卡片
                TotalValueCard(
                    totalValue: viewModel.totalValueInCNY,
                    valueChange: viewModel.totalValueChange
                )
                
                if viewModel.fundRecords.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .symbolEffect(.bounce, options: .nonRepeating.speed(0.5))
                            .onTapGesture {
                                HapticsManager.shared.play(.light)
                                showingAddSheet = true
                            }
                        
                        Text("轻触开启")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticsManager.shared.play(.light)
                        showingAddSheet = true
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(fundRecords) { fundRecord in
                            CoinRow(fundRecord: fundRecord, viewModel: viewModel)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteItem(viewModel.fundRecords[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("投资组合")
            .toolbar {
                Button(action: { showingAddSheet = true }) {
                    Label("添加", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCoinView(viewModel: viewModel)
            }
        }
        // 监听内存警告
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            Task {
                await ImageCache.shared.clear()
            }
        }
        // 监听应用进入前台
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                // 前台时刷新汇率
                if let rate = try? await PriceService.shared.fetchUsdToCnyRate() {
                    CurrencyConverter.usdToCNYRate = rate
                }
                try? await viewModel.refreshPrices()
            }
        }
        .onAppear {
            // 启动定时器，每30秒刷新一次
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                Task {
                    try? await viewModel.refreshPrices()
                }
            }
            // 首次加载时也刷新一次
            Task {
                try? await viewModel.refreshPrices()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

struct ValueChange: Equatable {
    let amount: Double
    let percentage: Double
}

struct TotalValueCard: View {
    let totalValue: Double
    let valueChange: ValueChange?
    @State private var isLoading = true // 添加加载状态
    
    var body: some View {
        VStack(spacing: 8) {
            // 总资产估值和汇率在同一行
            HStack {
                // 左侧占位，用于平衡布局
                Text("1:\(String(format: "%.2f", CurrencyConverter.usdToCNYRate))")
                    .font(.caption)
                    .foregroundColor(.clear) // 透明，用于占位
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.clear)
                    .cornerRadius(8)
                
                Spacer()
                
                // 总资产估值居中显示
                Text("总资产估值")
                    .font(.headline)
                    .foregroundColor(Color.orange)
                
                Spacer()
                
                // 显示当前汇率
                Text("1:\(String(format: "%.2f", CurrencyConverter.usdToCNYRate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            // 总资产金额
            Text(CurrencyConverter.formatCNY(totalValue))
                .font(.system(size: 36))
                .bold()
            
            if totalValue > 0 {
                if isLoading {
                    // 加载状态显示
                    ProgressView()
                        .scaleEffect(0.8)
                } else if let change = valueChange {
                    HStack(spacing: 12) {
                        // 显示涨跌金额
                        Text(formatChangeAmount(change.amount))
                            .foregroundColor(change.amount >= 0 ? .green : .red)
                        
                        // 显示涨跌百分比
                        Text(formatChangePercentage(change.percentage))
                            .foregroundColor(change.percentage >= 0 ? .green : .red)
                    }
                    .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
        .onChange(of: valueChange) { oldValue, newValue in
            isLoading = false
        }
    }
    
    private func formatChangeAmount(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(CurrencyConverter.formatCNY(value))"
    }
    
    private func formatChangePercentage(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
}

struct CoinRow: View {
    let fundRecord: FundRecord
    let viewModel: PortfolioViewModel
    @State private var showingAmountInput = false
    
    private var cryptoToken: CryptoToken? {
        CryptoToken.supportedCurrencies.first { $0.symbol == fundRecord.coinSymbol }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 上行：Logo、名称和人民币价值
            HStack(spacing: 4) {
                if let logoURL = cryptoToken?.logoURL {
                    CachedAsyncImage(url: logoURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                }
                
                Text(fundRecord.coinName)
                    .font(.headline)
                
                Spacer()
                
                Text(CurrencyConverter.formatCNY(fundRecord.valueInCNY))
                    .font(.headline)
            }
            
            // 下行：数量、符号、价格和涨跌幅
            HStack {
                Button {
                    HapticsManager.shared.play(.light)
                    showingAmountInput = true
                } label: {
                    Text("\(String(format: "%.8f", fundRecord.amount)) \(fundRecord.coinSymbol)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("\(String(format: "%.2f", fundRecord.priceInUSD)) USDT")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let priceChange = viewModel.getPriceChange(for: fundRecord.coinSymbol) {
                        Text(formatPercentage(priceChange))
                            .font(.subheadline)
                            .foregroundColor(priceChange >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingAmountInput) {
            AmountEditView(
                initialAmount: fundRecord.amount
            ) { newAmount in
                viewModel.updateAmount(for: fundRecord, newAmount: newAmount)
            }
            .presentationDetents([.fraction(0.3)])
        }
    }
    
    private func formatPercentage(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
}

// 添加新的 AmountEditAlert 视图
struct AmountEditAlert: View {
    let initialAmount: Double
    let onSubmit: (Double) -> Void
    
    @State private var amountText: String
    
    init(initialAmount: Double, onSubmit: @escaping (Double) -> Void) {
        self.initialAmount = initialAmount
        self.onSubmit = onSubmit
        _amountText = State(initialValue: String(format: "%.8f", initialAmount))
    }
    
    var body: some View {
        TextField("输入数量", text: $amountText)
            .keyboardType(.decimalPad)
        
        Button("确定") {
            if let amount = Double(amountText) {
                onSubmit(amount)
            }
        }
        
        Button("取消", role: .cancel) { }
    }
}


