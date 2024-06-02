//
//  SelectStampView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/02.
//

import SwiftUI

struct SelectStampCell: View {
    @Binding var postStamp: UIImage
    @Binding var showSelectStampView: Bool
    var items = [
            "stamp1", "stamp2", "stamp3", "stamp4", "stamp5", "stamp6"
        ]
    var body: some View {
        VStack {
            Text("今の気持ちに一番近いスタンプを選ぼう！")
                .fontWeight(.bold)
                .padding(.bottom, 50)
            LazyVGrid(columns: Array(repeating: .init(), count: 3), spacing: 20) {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        postStamp = UIImage(named: item)!
                        showSelectStampView = false
                    }, label: {
                        Image(item)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    })
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @State var image = UIImage(named: "hiyo")!
    @State var bool = true
    return SelectStampCell(postStamp: $image, showSelectStampView: $bool)
}
