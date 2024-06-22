//
//  PositiveWordsCollectionApp.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/17.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

@main
struct PositiveWordsCollectionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
                ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
      let providerFactory = MyAppCheckProviderFactory()
      AppCheck.setAppCheckProviderFactory(providerFactory)
      FirebaseApp.configure()
    return true
  }
}
