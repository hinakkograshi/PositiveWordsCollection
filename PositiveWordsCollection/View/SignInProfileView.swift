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
    @State var selectedImage: UIImage = UIImage(named: "hiyoko")!
    @State var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    @Environment (\.presentationMode) var presentationMode
    @State var showImagePicker: Bool = false
    var body: some View {
        NavigationStack {
            HStack {
                VStack {
                    Text("プロフィール画像")
                        .font(.title2)
                        .fontWeight(.bold)
                    Button(action: {
                        showImagePicker.toggle()
                    }, label: {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
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
        }
    }
}

#Preview {
    @State var selectedImage = UIImage(named: "hiyoko")!
    return SignInProfileView(selectedImage: selectedImage)
}
