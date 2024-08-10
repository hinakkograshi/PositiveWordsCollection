//
//  PostImageView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/08/10.
//

import SwiftUI

struct PostImageView: View {
    let displayingPostImage: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Image(uiImage: displayingPostImage)
            .resizable()
            .scaledToFill()
            .frame(width: 350, height: 350)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("✖️")
                            .font(.largeTitle)
                    })
                }
            }
    }
}

#Preview {
    PostImageView(displayingPostImage: UIImage(named: "loading")!)
}
