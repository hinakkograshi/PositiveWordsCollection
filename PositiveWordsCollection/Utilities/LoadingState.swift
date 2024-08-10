//
//  LoadingState.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/08/10.
//

import Foundation

enum  LoadingState {
    /// 初期状態
    case idle
    /// ロード中
    case loading
    /// 成功
    case success
    /// 失敗
    case failure

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
