//
//  Decimal+Extensions.swift
//  dniCalculator
//
//  Created by Jeff Hitchcock on 2019-09-01.
//  Copyright © 2019 Jeff Hitchcock. All rights reserved.
//

import Foundation

internal extension Decimal {
    /// Convert the decimal into an interger discarding anything fractional component.
    var intValue: Int {
        let decimalNumber = NSDecimalNumber(decimal: self)
        return Int(truncating: decimalNumber)
    }

    /// Round the decimal down to the nearest integer value.
    ///
    /// - Returns: Number rounded down to the nearest whole number.
    func floored() -> Decimal {
        var starting = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &starting, 0, .down)
        return rounded
    }
}
