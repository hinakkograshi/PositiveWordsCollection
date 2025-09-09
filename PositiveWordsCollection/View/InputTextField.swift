//
//  InputTextField.swift
//  PositiveWordsCollection
//
//  Created by Fukagi Hina on 2025/09/01.
//

import SwiftUI

struct InputTextField<FocusedValue: Hashable>: View {
    @Binding private var text: String
    private var maxCount: Int
    private var placeHolder: String
    private var focused: (FocusState<FocusedValue>.Binding, FocusedValue)
    @State private var inputState: InputState = .before

    var body: some View {
        let _ = print("⭐️InputTextField更新")
        VStack(spacing: 4) {
            TextField(
                "\(placeHolder)(\(maxCount)文字以内)",
                text: $text
            )
            .textFieldStyle(.roundedBorder)
            HStack {
                Spacer()
                // 入力文字数の表示
                Text(" \(text.count) / \(maxCount)")
            }
        }
        // 10文字以上の時最後の文字を削除制限
        .onChange(of: text) {
            if $0.count > maxCount {
                text.removeLast($0.count - maxCount)
            }
        }
        .onChange(of: focused.0.wrappedValue) {
            _ = print("⭐️\($0)")
            if $0 == focused.1 { // 自身にフォーカスが当たる
                inputState = .editing
            } else if case .editing = inputState { // 自身からフォーカスが外れる
                inputState = .finished
            }
        }
        .ifLet(focused) {
            // ref: https://qiita.com/SNQ-2001/items/4caf34bab15702d3abdf
            $0.focused($1.0.projectedValue, equals: $1.1)
        }
    }
}

extension InputTextField {
    init(
        inputTxet: Binding<String>,
        count: Int,
        placeHolderText: String,
        focused: FocusState<FocusedValue>.Binding,
        equals focusedValue: FocusedValue
    ) {
        self.init(
            text: inputTxet,
            maxCount: count,
            placeHolder: placeHolderText,
            focused: (focused, focusedValue)
        )
    }

    enum InputState {
        case before
        case editing
        case finished
    }
}

// MARK: -
private extension View {
    @ViewBuilder
    func ifLet<Wrapped, Content: View>(
        _ wrapped: Wrapped?,
        @ViewBuilder transform: (Self, Wrapped) -> Content
    ) -> some View {
        if let wrapped {
            transform(self, wrapped)
        } else {
            self
        }
    }
}
