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
                .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        #else
        let providerFactory = MyAppCheckProviderFactory()
        #endif
        AppCheck.setAppCheckProviderFactory(providerFactory)

        firebaseConfigure()
        FirebaseApp.configure()
        return true
    }
    private func firebaseConfigure() {
        #if DEBUG
        let filePath = Bundle.main.path(forResource: "GoogleService-Stage-Info", ofType: "plist")
        #else
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        #endif

        guard let filePath = filePath else {
            return
        }

        guard FirebaseOptions(contentsOfFile: filePath) != nil else {
            return
        }
    }
}
