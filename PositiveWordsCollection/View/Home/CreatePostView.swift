//
//  CreatePostView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import SwiftUI

struct CreatePostView: View {
    @State var nameText = ""
    @State var bioText = ""
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {

                }, label: {
                    Rectangle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 150, height: 150)
                        .overlay {
                            VStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                Text("スタンプを追加")
                            }
                        }
                })
                .padding(.vertical, 50)
                VStack(alignment: .leading) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $bioText)
                            .frame(height: 150)
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue, lineWidth: 2)
                            }
                        if bioText.isEmpty {
                            Text("今日はどんな良いことがありましたか？").foregroundStyle(Color(uiColor: .placeholderText))
                                .padding(8)
                                .allowsHitTesting(false)
                        }

                    }

                }
                Divider()
                Spacer()
            }
            .padding()
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {

                    }, label: {
                        Text("キャンセル")
                            .tint(.primary)
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {

                    }, label: {
                        Text("保存")
                            .tint(.primary)
                    })
                }
            }
        }
    }
}

#Preview {
    CreatePostView()
}
