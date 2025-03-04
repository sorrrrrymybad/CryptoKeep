import SwiftUI
import SwiftData

struct AmountEditView: View {
    @Environment(\.dismiss) private var dismiss
    let initialAmount: Double
    let title: String
    let onSubmit: (Double) -> Void
    
    @State private var amountText: String
    @FocusState private var isAmountFocused: Bool
    
    init(initialAmount: Double, title: String = "修改持有数量", onSubmit: @escaping (Double) -> Void) {
        self.initialAmount = initialAmount
        self.title = title
        self.onSubmit = onSubmit
        _amountText = State(initialValue: String(format: "%.4f", initialAmount))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("输入数量", text: $amountText)
                            .keyboardType(.decimalPad)
                            .focused($isAmountFocused)
                        
                        if !amountText.isEmpty {
                            Button {
                                amountText = ""
                                isAmountFocused = true
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        if let amount = Double(amountText) {
                            onSubmit(amount)
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            isAmountFocused = true
        }
    }
}
