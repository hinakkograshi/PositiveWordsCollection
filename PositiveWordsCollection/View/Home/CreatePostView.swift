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
    @State var postStamp = UIImage(named: "loading")!
    @State var showSelectStampView = false
    @Environment(\.dismiss) private var dismiss
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    showSelectStampView = true
                }, label: {
                    if postStamp != UIImage(named: "loading") {
                        Image(uiImage: postStamp)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.orange, lineWidth: 3.0)
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.orange, lineWidth: 3.0)
                            .frame(width: 150, height: 150)
                            .overlay {
                                VStack {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .tint(.orange)
                                        .frame(width: 50, height: 50)
                                    Text("スタンプを追加")
                                        .tint(.orange)
                                        .fontWeight(.bold)
                                }
                            }
                    }
                })
                .padding(.vertical, 30)
                VStack(alignment: .leading) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $bioText)
                            .frame(height: 200)
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange, lineWidth: 3)
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
            .navigationTitle("ポスト")
            .navigationBarTitleDisplayMode(.inline)
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
                        postPicture()
                        dismiss()
                    }, label: {
                        Text("保存")
                            .tint(.primary)
                    })
                }
            }
        }
        .overlay {
            if showSelectStampView == true {
                Color.black.opacity(0.3)
                VStack {
                    SelectStampCell(postStamp: $postStamp, showSelectStampView: $showSelectStampView)
                }
                .frame(width: 300, height: 400)
                .background()
            }
        }
    }
    // FUNCTION
    func postPicture() {
        print("Post picture to DB here")
        guard let userID = currentUserID, let displayName = currentUserName else {
            print("Error getting userOD or displayname posting image")
            return
        }
        Task {
            await DataService.instance.uploadPost(image: postStamp, caption: bioText, displayName: displayName, userID: userID)
        }
    }
}

#Preview {
    CreatePostView()
}
