//
//  MyAppCheckProviderFactory.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/22.
//

import Foundation
import FirebaseAppCheck
import FirebaseCore

class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return AppAttestProvider(app: app)
  }
}
