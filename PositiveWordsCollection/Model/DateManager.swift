//
//  DateManager.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/09/15.
//

import Foundation

struct DateManager {
    static func stringFromCreatedDate(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        // 現在の日時と指定された日付の差分を計算
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let day = components.day, day >= 1 {
            // 24時間以上経過している場合は通常のフォーマットで表示
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "yyyy/M/d"
            return dateFormatter.string(from: date)
        } else if let hour = components.hour, hour >= 1 {
            // 1時間以上24時間未満の場合は「◯◯時間前」
            return "\(hour)時間前"
        } else if let minute = components.minute, minute >= 1 {
            // 1分以上1時間未満の場合は「◯◯分前」
            return "\(minute)分前"
        } else {
            // 1分未満の場合は「たった今」
            return "たった今"
        }
    }
}
