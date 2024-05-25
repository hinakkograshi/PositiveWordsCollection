//
//  PostCell.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/21.
//

import SwiftUI

struct PostCell: View {
    @State var post: PostModel
    @State var postStamp: UIImage = UIImage(named: "hiyo")!
    @State var animateLike: Bool = false
    @State var showActionSheet: Bool = false
    var body: some View {
        VStack {
            // header
            HStack {
                NavigationLink(destination: {
                    ProfileView(isMyProfile: false, profileDisplayName: post.username, profileUserID: post.userID)
                }, label: {
                    Image("hiyoko")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    Text(post.username)
                        .font(.callout)
                        .fontWeight(.medium)
                        .tint(.primary)
                    // Time
                    Text("2s")
                        .foregroundStyle(.gray)
                        .font(.caption)
                    // light and dark mode対応
                        .foregroundStyle(.primary)
                })
                Spacer()
                Button(action: {
                    showActionSheet.toggle()
                },
                       label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                })
                .tint(.primary)
                .confirmationDialog("What would you like to do?", isPresented: $showActionSheet, titleVisibility: .visible) {
                    Button("Report", role: .destructive) {
                        print("Report Post")
                    }
                    Button("Learn more...") {
                        print("Learn more pressed")
                    }
                }
            }
            Divider()
            // Content
            HStack {
                // stamp Image
                Image(uiImage: postStamp)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80, alignment: .center)
                // post caption
                Text("今日は仕事頑張った!先輩にいつも前向きに頑張っててえらいね！と言われた！\n先輩の方こそ偉いですよって言った！")
                    .font(.subheadline)
                    .padding(.leading, 20)
                Spacer()
            }
            .padding()
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    if post.likedByUser {
                        unLikePost()
                    } else {
                        likePost()
                    }
                }, label: {
                    Image(systemName: post.likedByUser ? "heart.fill" : "heart")
                        .font(.title3)
                })
                .tint(post.likedByUser ? .red : .primary)
                // MARK: Comment Icon
                HStack {
                    NavigationLink(
                        destination: CommentsView(post: $post),
                        label: {
                            Image(systemName: "bubble.middle.bottom")
                                .font(.title3)
                                .tint(.primary)
                        })
                    Text("0")
                    .font(.subheadline)                }
                Image(systemName: "paperplane")
                    .font(.title3)
                Spacer()
            }
            Rectangle()
                .frame(height: 1)
        }
    }
    // MARK: function
    func likePost() {
        // Update the local data
        let updatePost = PostModel(postID: post.postID, userID: post.userID, username: post.username, dateCreated: post.dateCreated, likeCount: post.likeCount + 1, likedByUser: true)
        self.post = updatePost

        animateLike = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            animateLike = false
        }
    }

    func unLikePost() {
        let updatePost = PostModel(postID: post.postID, userID: post.userID, username: post.username, dateCreated: post.dateCreated, likeCount: post.likeCount - 1, likedByUser: false)
        self.post = updatePost

    }
    // MARK:24.メソッド数個省略
    // X等にコピーする内容
    func sharePost() {
        let message = "Check out this post on DogGram"
        let image = postStamp
        let link = URL(string: "https://www.google.com")!
        let activityViewController =  UIActivityViewController(activityItems: [message, image, link], applicationActivities: nil)
        let viewController =  UIApplication.shared.windows.first?.rootViewController
        viewController?.present(activityViewController, animated: true, completion: nil)

    }
}

#Preview {
    let post = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption",dateCreated: Date(), likeCount: 0, likedByUser: false)
    return PostCell(post: post)
}
