//
//  TimeFormatting.swift
//  MacIsland
//

import Foundation

enum IslandTime {
    static func label(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        if total >= 3600 {
            return String(
                format: "%d:%02d:%02d",
                total / 3600,
                (total % 3600) / 60,
                total % 60
            )
        }
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
