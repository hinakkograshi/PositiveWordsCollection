//
//  Utilities.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/19.
//

import UIKit

final class Utilities {
    static let shared = Utilities()
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let controller = controller ?? windowScene?.windows.first?.rootViewController
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
