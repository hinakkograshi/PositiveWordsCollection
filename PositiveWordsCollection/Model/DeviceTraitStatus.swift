//
//  UserInterfaceSizeClass.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/10/02.
//

import SwiftUI

enum DeviceTraitStatus {
    case iPhoneHeight
    case iPhoneWidth
    case iPhoneLargeWidth
    case iPad

    init(hSizeClass: UserInterfaceSizeClass?, vSizeClass: UserInterfaceSizeClass?) {
        switch (hSizeClass, vSizeClass) {
        case (.compact, .regular):
            self = .iPhoneHeight
        case (.compact, .compact):
            self = .iPhoneWidth
        case (.regular, .compact):
            self = .iPhoneLargeWidth
        case (.regular, .regular):
            self = .iPad
        default:
            self = .iPhoneHeight
        }
    }
}
