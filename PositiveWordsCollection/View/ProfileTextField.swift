//
//  ProfileTextField.swift
//  PositiveWordsCollection
//
//  Created by Fukagi Hina on 2025/09/09.
//

import SwiftUI

struct ProfileTextField<FocusedValue: Hashable>: View {
    private var focused: (FocusState<FocusedValue>.Binding, FocusedValue)
    @Binding private var text: String
    private var maxCount: Int
    private var placeHolder: String
    @State private var inputState: InputState = .before

    init(
        inputTxet: Binding<String>,
        count: Int,
        placeHolderText: String,
        focused: FocusState<FocusedValue>.Binding,
        equals focusedValue: FocusedValue
    ) {
        _text = inputTxet
        self.maxCount = count
        self.placeHolder = placeHolderText
        self.focused = (focused, focusedValue)
    }
    var body: some View {
        VStack(spacing: 4) {
            InputTextField(
                inputTxet: $text,
                count: maxCount,
                placeHolderText: placeHolder,
                focused: focused.0,
                equals: focused.1
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
    }
}

extension ProfileTextField {
    enum InputState {
        case before
        case editing
        case finished
    }
}

// #Preview {
//    ProfileTextField()
// }
