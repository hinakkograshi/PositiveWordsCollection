//
//  UITextView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/10/18.
//

import UIKit
import SwiftUI

struct TextViewWrapper: UIViewRepresentable {
    // 受け取りたいデータをプロパティとして定義する
    let text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link] // URL 検出を有効にする
        textView.text = text
        // リンクの色を指定する
        textView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.label
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    // iOS16未満では利用不可能
//    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIViewType, context: Context) -> CGSize? {
//        guard let width = proposal.width, let height = proposal.height else {
//            return nil
//        }
//        return .init(width: width, height: height)
//    }
}
