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
    @Binding var profileImage: UIImage
    @State var selectedImage = UIImage(named: "loading")!
    @State var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    @Environment (\.presentationMode) var presentationMode
    @State var showImagePicker: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    showImagePicker.toggle()
                }, label: {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 75))
                        .overlay {
                            RoundedRectangle(cornerRadius: 75)
                                .stroke(Color.orange, lineWidth: 3.0)
                        }
                })
                Button(action: {
                    showImagePicker.toggle()
                }, label: {
                    Text("ライブラリから画像を選択")
                })
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(imageSelection: $selectedImage, sourceType: $sourceType)
                }
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
    @State var image = UIImage(named: "hiyoko")!
    return EditProfileView(profileImage: $image, selectedImage: image)
}
