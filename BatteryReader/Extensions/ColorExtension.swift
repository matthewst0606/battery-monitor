//
//  ColorExtension.swift
//  Battery Monitor
//
//  Created by Matt on 6/1/26.
//

import SwiftUI

extension Color {
    func colorToData() -> Data? {
        let nsColor = NSColor(self)
        return try? NSKeyedArchiver
            .archivedData(
                withRootObject: nsColor,
                requiringSecureCoding: false
            )
    }
    static func dataToColor(from data: Data) -> Color? {
        if let nsData = try? NSKeyedUnarchiver
            .unarchivedObject(
                ofClass: NSColor.self,
                from: data
            ) {
            return Color(nsColor: nsData)
        }
        return nil
    }
}
