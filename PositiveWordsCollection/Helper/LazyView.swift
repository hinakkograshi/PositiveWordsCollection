//
//  LazyView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/04.
//

import Foundation
import SwiftUI

struct LazyView<Content: View>: View {
    var content: () -> Content
    // 遷移した瞬間、bodyにアクセスされる
    var body: some View {
        self.content()
    }
}
