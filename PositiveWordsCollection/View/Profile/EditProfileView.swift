//
//  EditProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct EditProfileView: View {
    @State var nameText = ""
    @State var bioText = ""
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {

                }, label: {
                    Image("hiyoko")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .opacity(0.8)
                        .overlay {
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                                .frame(width: 150, height: 150)
                        }
                })
                .padding(.bottom, 50)
                Divider()
                HStack {
                    Text("名前")
                        .fontWeight(.bold)
                        .padding()
                    TextField("名前", text: $nameText)
                        .textFieldStyle(.roundedBorder)
                }
                Divider()
                HStack {
                    Text("自己紹介")
                        .fontWeight(.bold)
                        .padding()
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $bioText)
                            .frame(height: 100)
                            .border(Color.black)
                        if bioText.isEmpty {
                            Text("自己紹介").foregroundStyle(Color(uiColor: .placeholderText))
                                .padding(8)
                                .allowsHitTesting(false)
                        }

                    }

                }
                Divider()
            }

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
    EditProfileView()
}
