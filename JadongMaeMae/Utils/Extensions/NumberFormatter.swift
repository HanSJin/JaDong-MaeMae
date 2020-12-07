//
//  NumberFormatter.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/08.
//

import Foundation

extension NumberFormatter {

    // MARK: Internal

    /// If value is 123456 integer, return string is "123,456"
    static func decimalFormat(_ value: Int) -> String {
        guard let decimalString = decimalNumberFormatter.string(from: NSNumber(value: value)) else {
            return ""
        }
        return decimalString
    }
    
    static func currencyFormat(_ value: Double) -> String {
        guard let decimalString = decimalNumberFormatter.string(from: NSNumber(value: value)) else {
            return ""
        }
        return decimalString
    }

    // MARK: Private

    private static let decimalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
