import SwiftUI
import SwiftData

struct AmountEditView: View {
    @Environment(\.dismiss) private var dismiss
    let initialAmount: Double
    let title: String
    let onSubmit: (Double) -> Void
    
    @State private var amountText: String
    @FocusState private var isAmountFocused: Bool
    @State private var showingCalculator = false
    @State private var calculatorValue: Double = 0
    
    init(initialAmount: Double, title: String = "修改持有数量", onSubmit: @escaping (Double) -> Void) {
        self.initialAmount = initialAmount
        self.title = title
        self.onSubmit = onSubmit
        _amountText = State(initialValue: String(format: "%.8f", initialAmount))
        _calculatorValue = State(initialValue: initialAmount)
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
                    
                    // 计算器按钮
                    Button {
                        showingCalculator = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.forwardslash.minus")
                            Text("使用计算器")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // 显示计算器结果
                if calculatorValue != initialAmount {
                    Section("计算器结果") {
                        HStack {
                            Text("计算结果:")
                            Spacer()
                            Text(String(format: "%.8f", calculatorValue))
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                        
                        Button("使用此结果") {
                            amountText = String(format: "%.8f", calculatorValue)
                            calculatorValue = initialAmount
                        }
                        .foregroundColor(.green)
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
        .sheet(isPresented: $showingCalculator) {
            CalculatorView(
                initialValue: Double(amountText) ?? 0,
                onResult: { result in
                    calculatorValue = result
                    showingCalculator = false
                }
            )
            .presentationDetents([.height(400)])
        }
        .onAppear {
            isAmountFocused = true
        }
    }
}

// 新增计算器视图
struct CalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    let initialValue: Double
    let onResult: (Double) -> Void
    
    @State private var currentValue: Double
    @State private var inputValue: String = ""
    
    init(initialValue: Double, onResult: @escaping (Double) -> Void) {
        self.initialValue = initialValue
        self.onResult = onResult
        _currentValue = State(initialValue: initialValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 显示当前值
                VStack {
                    Text("当前值")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.8f", currentValue))
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // 输入框
                HStack {
                    Text("调整值:")
                    TextField("输入数值", text: $inputValue)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // 计算按钮
                HStack(spacing: 20) {
                    Button("增加") {
                        if let value = Double(inputValue) {
                            currentValue += value
                            inputValue = ""
                        }
                    }
                    .buttonStyle(CalculatorButtonStyle())
                    
                    Button("减少") {
                        if let value = Double(inputValue) {
                            currentValue -= value
                            inputValue = ""
                        }
                    }
                    .buttonStyle(CalculatorButtonStyle())
                }
                
                // 快速调整按钮
//                VStack(spacing: 10) {
//                    Text("快速调整")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    HStack(spacing: 15) {
//                        ForEach([100, 1000], id: \.self) { value in
//                            Button("+\(value)") {
//                                currentValue += value
//                            }
//                            .buttonStyle(QuickAdjustButtonStyle())
//                        }
//                    }
//                    
//                    HStack(spacing: 15) {
//                        ForEach([0.1, 0.5], id: \.self) { value in
//                            Button("-\(value)") {
//                                currentValue -= value
//                            }
//                            .buttonStyle(QuickAdjustButtonStyle())
//                        }
//                    }
//                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("计算器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        onResult(currentValue)
                    }
                }
            }
        }
    }
}

// 计算器按钮样式
struct CalculatorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(Color.blue)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// 快速调整按钮样式
struct QuickAdjustButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
