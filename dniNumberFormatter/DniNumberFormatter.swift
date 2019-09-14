//
//  DniNumberFormatter.swift
//  dniClock
//
//  Created by Jeff Hitchcock on 2019-07-02.
//  Copyright © 2019 Jeff Hitchcock. All rights reserved.
//

import Foundation

public class DniNumberFormatter: Formatter {
    /// The maximum number of digits before the radix seperator.
    public var minimumIntegerDigits: Int = 0
    /// The minimum number of digits before the radix seperator.
    public var maximumIntegerDigits: Int = 42
    /// The minimum number of digits after the radix separator.
    public var minimumFractionDigits: Int = 0
    /// The maximum number of digits after the radix separator.
    public var maximumFractionDigits: Int = 10

    /// Character used to seperate the integer and fractional parts of the number.
    public var radixSeparator: String = "."


    override public func string(for object: Any?) -> String? {
        guard let number = object as? Double else { return nil }

        return string(forNumber: Decimal(floatLiteral: number))
    }

    public func string(forNumber number: Decimal) -> String? {
        var (integer, fraction) = DniNumberFormatter.base25Components(number, maximumFractionDigits: maximumFractionDigits)

        // Pad values with zero if necessary
        if integer.count < minimumIntegerDigits {
            var newArray = Array(repeating: 0, count: minimumIntegerDigits - integer.count)
            newArray.append(contentsOf: integer)
            integer = newArray
        } else if integer.count > maximumIntegerDigits {
            integer.removeFirst(integer.count - maximumIntegerDigits)
        }
        if fraction.count < minimumFractionDigits {
            fraction.append(contentsOf: Array(repeating: 0, count: minimumFractionDigits - fraction.count))
        } else if fraction.count > maximumFractionDigits {
            fraction.removeLast(fraction.count - maximumFractionDigits)
        }

        // Remove unnecessary zeroes from fraction.
        if fraction.count > minimumFractionDigits {
            while fraction.count > minimumFractionDigits && fraction.last == 0 {
                fraction.removeLast()
            }
        }

        var string = integer.map {
            DniNumberFormatter.digitAsString($0)
        }.joined()

        if !fraction.isEmpty {
            string += radixSeparator + fraction.map { DniNumberFormatter.digitAsString($0) }.joined()
        }

        return string
    }

    public class func digitAsString(_ digit: Int, cyclic: Bool = false) -> String {
        precondition(digit >= 0 && digit <= 25, "Single D'ni numbers must be between 0 and 25.")
        #if DEBUG
        if digit >= 25 {
            print("Hmm: \(digit)")
        }
        #endif

        switch digit {
        case 10:
            return ")"
        case 11:
            return "!"
        case 12:
            return "@"
        case 13:
            return "#"
        case 14:
            return "$"
        case 15:
            return "%"
        case 16:
            return "^"
        case 17:
            return "&"
        case 18:
            return "*"
        case 19:
            return "("
        case 20:
            return "["
        case 21:
            return "]"
        case 22:
            return "\\"
        case 23:
            return "{"
        case 24:
            return "}"
        case 25:
            return cyclic ? "=" : "|"
        case 0:
            return cyclic ? "=" : "0"
        default:
            return "\(digit)"
        }
    }
}

// MARK: Splitting Number
extension DniNumberFormatter {
    class func base25Components(_ number: Decimal, maximumFractionDigits: Int = 10) -> ([Int], [Int]) {
        var integralData = CalcData(number: number.floored())
        let fractional = number - integralData.number
        _base25WalkUp(data: &integralData)

        var fractionalData = CalcData(number: fractional)
        _base25WalkDown(data: &fractionalData, maxDigits: maximumFractionDigits)

        return (integralData.components, fractionalData.components)
    }

    fileprivate struct CalcData {
        var number: Decimal
        var components: [Int] = []
    }

    fileprivate class func _base25WalkUp(_ power: Decimal = 1, data: inout CalcData) {
        let nextPower = power * 25
        if data.number >= nextPower {
            _base25WalkUp(nextPower, data: &data)
            data.number -= Decimal(data.components.last!) * nextPower
        }
        data.components.append((data.number / power).intValue)
    }

    fileprivate class func _base25WalkDown(_ power: Decimal = 0.04, data: inout CalcData, maxDigits: Int = 10) {
        data.components.append((data.number / power).intValue)
        data.number -= Decimal(data.components.last!) * power
        if maxDigits > 0 && data.number > 0 {
            _base25WalkDown(power / 25, data: &data, maxDigits: maxDigits - 1)
        }
    }
}
