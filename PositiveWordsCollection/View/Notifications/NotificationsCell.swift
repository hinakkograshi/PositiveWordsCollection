//
//  NotificationsCell.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/09/14.
//

import SwiftUI

struct NotificationsCell: View {
    var body: some View {
        VStack {
            Button {
                //isPostImageViewShowing = true
            } label: {
                Image(uiImage: UIImage(named: "loading")!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 60))
                    .overlay {
                        RoundedRectangle(cornerRadius: 60)
                            .stroke(Color.black, lineWidth: 1.0)
                    }
                    .padding(5)
                Spacer()
            }
            HStack {
                // post caption
                Text("hinakko")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                Text("さんがあなたの投稿にいいねしました！")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(5)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    NotificationsCell()
}
