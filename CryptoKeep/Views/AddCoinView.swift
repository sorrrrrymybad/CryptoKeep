import SwiftUI
import SwiftData

struct AddCoinView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: PortfolioViewModel
    
    @State private var selectedCryptoToken: CryptoToken?
    @State private var showingAmountInput = false
    @State private var amountText = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(CryptoToken.supportedCurrencies) { cryptoToken in
                        CurrencySelectionRow(cryptoToken: cryptoToken, isSelected: selectedCryptoToken?.id == cryptoToken.id)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                HapticsManager.shared.play(.light)
                                selectedCryptoToken = cryptoToken
                                showingAmountInput = true
                            }
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("添加新币种")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        amountText = ""
                        selectedCryptoToken = nil
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAmountInput) {
                if let token = selectedCryptoToken {
                    AmountEditView(
                        initialAmount: 0,
                        title: "输入\(token.name)数量"
                    ) { amount in
                        Task {
                            await viewModel.addItem(
                                coinName: token.name,
                                coinSymbol: token.symbol,
                                amount: amount
                            )
                            dismiss()
                        }
                    }
                    .presentationDetents([.fraction(0.3)])
                }
            }
        }
    }
}

struct CurrencySelectionRow: View {
    let cryptoToken: CryptoToken
    let isSelected: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            CachedAsyncImage(url: cryptoToken.logoURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(cryptoToken.name)
                    .font(.headline)
                Text(cryptoToken.symbol)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .listRowBackground(Color.clear)
    }
}

struct AmountInputAlert: View {
    @Binding var amountText: String
    let onSubmit: (Double) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        TextField("输入数量", text: $amountText)
            .keyboardType(.decimalPad)
        
        Button("确定") {
            if let amount = Double(amountText) {
                onSubmit(amount)
            }
        }
        
        Button("取消", role: .cancel) {
            onCancel()
        }
    }
}

#Preview {
    NavigationStack {
        AddCoinView(viewModel: PortfolioViewModel(modelContext: try! ModelContainer(for: FundRecord.self).mainContext))
    }
} 
