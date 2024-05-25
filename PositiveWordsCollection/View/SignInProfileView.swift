//
//  SignInProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import SwiftUI

struct SignInProfileView: View {
    @Environment (\.dismiss) private var dismiss
    @State var nameText = ""
    @State var bioText = ""
    var body: some View {
        NavigationStack {
            HStack {
                VStack {
                    Image("hiyoko")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .opacity(0.8)
                        .overlay {
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.gray)
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                                .frame(width: 150, height: 150)
                        }
                        .padding(.bottom, 30)
                    Button(action: {

                    }, label: {
                        Text("プロフィール画像選択")
                    })

                    Divider()
                    HStack {
                        Text("名前")
                            .fontWeight(.bold)
                            .padding()
                        TextField("名前", text: $nameText)
                            .textFieldStyle(.roundedBorder)
                    }
                    Button {

                    } label: {
                        Text("登録")
                            .font(.headline)
                            .fontWeight(.bold)
                            .tint(.primary)
                            .padding()
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.MyTheme.yellowColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                }
            }

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
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
    SignInProfileView()
}
