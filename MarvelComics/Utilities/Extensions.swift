//
//  Extensions.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation
import UIKit
import SwiftUI

/// Extension to the `View` protocol that provides a method to hide the keyboard.
///
/// This extension adds a utility function to any SwiftUI `View`, allowing the keyboard to be dismissed
/// programmatically by resigning the first responder.
///
/// - Note: This method sends an action to resign the current first responder (the keyboard) using UIKit.

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Extension to the `Color` struct to initialize a color from a hexadecimal string.
///
/// This extension allows for the creation of a SwiftUI `Color` instance using a hex string.
/// It supports both 6-character (RGB) and 8-character (RGBA) hex codes, automatically handling conversion to the appropriate color values.
///
/// - Parameters:
///   - hex: A string representing the hex code of the color, optionally including a "#" at the beginning.
///          The hex string can be 6 characters (RGB) or 8 characters (RGBA).
///

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var red: Double = 0.0
        var green: Double = 0.0
        var blue: Double = 0.0
        var opacity: Double = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            red = Double((rgb & 0xFF0000) >> 16) / 255.0
            green = Double((rgb & 0x00FF00) >> 8) / 255.0
            blue = Double(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            red = Double((rgb & 0xFF000000) >> 24) / 255.0
            green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            opacity = Double(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
