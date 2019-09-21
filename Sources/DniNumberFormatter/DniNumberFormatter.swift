//
//  DniNumberFormatter.swift
//  dniClock
//
//  Created by Jeff Hitchcock on 2019-07-02.
//  Copyright © 2019 Jeff Hitchcock. All rights reserved.
//

import Foundation

/// A formatter that converts between base-10 numeric values and their base-25 representation.
public class DniNumberFormatter: Formatter {
    // MARK: Converting Between Numbers and Strings
    /// Attempt to convert the provided object into a number before converting.
    ///
    /// - Parameter object: Object that the formatter will attempt to convert into a number
    ///     for formatting.
    /// - Returns: Formatted string if conversion is positible, otherwise `nil`.
    override public func string(for object: Any?) -> String? {
        guard let number = object as? Double else { return nil }

        return string(forNumber: Decimal(floatLiteral: number))
    }

    /// Convert the provided decimal number into a base-25 string with D'ni encoding.
    ///
    /// - Parameter number: Base-10 number to format.
    /// - Returns: Number formatted in base-25 with D'ni encoding.
    public func string(forNumber number: Decimal) -> String {
        let (string, _) = formString(number)
        return string
    }

    /// Convert the provided decimal number into a base-25 string with D'ni encoding while
    /// keeping track of whether the number overflowed past `maximumIntegerDigits`.
    ///
    /// - Parameters:
    ///     - number: Base-10 number to format.
    ///     - overflowed: Boolean indicating whether the result overflowed.
    /// - Returns: Number formatted in base-25 with D'ni encoding.
    public func string(forNumber number: Decimal, trackingOverflow overflowed: inout Bool) -> String {
        let (string, over) = formString(number)
        overflowed = over
        return string
    }

    /// Returns the string representation for a single D'ni digit.
    ///
    /// - Parameter digit: Number to convert into a D'ni string. Shoule be between
    ///     0 and 25 inclusive.
    /// - Returns: String that coresponds to the prodivded digit or `nil` if provided
    ///     value cannot be represented by a single D'ni digit.
    public func string(forDigit digit: Int) -> String? {
        guard digit >= 0 && digit <= 25 else { return nil }
        return String(DniNumberFormatter.characterForDigit(digit))
    }

    // MARK: Configuring Rounding Behavior
    /// The rounding behavior used when fewer decimals are available then displayable.
    public var roundingMode: RoundingMode = .nearest

    /// These constants are used to specify how numbers should be rounded.
    public enum RoundingMode {
        /// Round towards positive infinity.
        case ceiling
        /// Round towards negative infinity.
        case floor

        /// Round towards zero.
        case down
        /// Round away from zero.
        case up

        /// Round towards nearest integer.
        case nearest
    }

    // MARK: Configuring Integer and Fraction Digits
    /// The maximum number of digits before the radix seperator.
    ///
    /// The default value of this property is 0.
    public var minimumIntegerDigits: Int = 0

    /// The minimum number of digits before the radix seperator.
    ///
    /// The default value of this property is 42.
    public var maximumIntegerDigits: Int = 42

    /// The minimum number of digits after the radix separator.
    ///
    /// The default value of this property is 0.
    public var minimumFractionDigits: Int = 0

    /// The maximum number of digits after the radix separator.
    ///
    /// The default value of this property is 10.
    public var maximumFractionDigits: Int = 10

    // MARK: Configuring Numeric Symbols
    /// The string used to represent a minus sign.
    ///
    /// The default value of this property is "−".
    public var minusSign: String = "−"

    /// The string used to represent a plus sign.
    ///
    /// The default value of this property is "+".
    public var plusSign: String = "+"

    // MARK: Configuring Seperators and Grouping Size
    /// The string used to seperate integers into groups of digits.
    ///
    /// The default value of this property is ",".
    public var groupingSeparator: String = ","

    /// Determines whether the formatted number displays the group separator.
    ///
    /// The default value of this property is `false`.
    public var usesGroupingSeparator: Bool = false

    /// The size of groups to separate with the grouping separator.
    ///
    /// The default value of this property is 3.
    public var groupingSize: Int = 3

    /// Character used to seperate the integer and fractional parts of the number.
    ///
    /// The default value of this property is ".".
    public var radixSeparator: String = "."
}

extension DniNumberFormatter {
    fileprivate class func characterForDigit(_ digit: Int, cyclic: Bool = false) -> Character {
        precondition(digit >= 0 && digit <= 25, "Single D'ni numbers must be between 0 and 25.")

        switch digit {
        case 10: return ")"
        case 11: return "!"
        case 12: return "@"
        case 13: return "#"
        case 14: return "$"
        case 15: return "%"
        case 16: return "^"
        case 17: return "&"
        case 18: return "*"
        case 19: return "("
        case 20: return "["
        case 21: return "]"
        case 22: return "\\"
        case 23: return "{"
        case 24: return "}"
        case 25: return cyclic ? "=" : "|"
        case 0: return cyclic ? "=" : "0"
        default: return digit.description.first!
        }
    }

    @available(*, deprecated, message: "Use string(forDigit:cyclic:) instead.")
    public class func digitAsString(_ digit: Int, cyclic: Bool = false) -> String {
        return String(DniNumberFormatter.characterForDigit(digit, cyclic: cyclic))
    }
}

extension DniNumberFormatter {
    /// Create a formatted string from the provided number using the system's settings.
    ///
    /// - Parameter number: Number to format into a string.
    /// - Returns: String with the number formatted in base-25 D'ni style & boolean indicating whether
    ///     the integral values overflowed past `maximumIntegerDigits`.
    fileprivate func formString(_ number: Decimal) -> (result: String, overflowed: Bool) {
        var (integral, fractional, isNegative) = DniNumberFormatter.base25Components(number, maximumFractionDigits: maximumFractionDigits + 1)

        let overflowed = respectMinMaxDigits(&integral, &fractional, isNegative: isNegative)

        // Remove unnecessary zeroes from fraction.
        if fractional.count > minimumFractionDigits {
            while fractional.count > minimumFractionDigits && fractional.last == 0 {
                fractional.removeLast()
            }
        }

        var string = String(integral.map {
            DniNumberFormatter.characterForDigit($0)
        })

        if !fractional.isEmpty {
            string += radixSeparator + String(fractional.map { DniNumberFormatter.characterForDigit($0) })
        }

        if isNegative && string != "0" {
            string = "\(minusSign)\(string)"
        }

        return (result: string, overflowed: overflowed)
    }

    /// Add or remove digits from the integral and fractional portions to respect the minimum & maximum values.
    ///
    /// - Parameters:
    ///     - integral: Array of digits in the portion of the number before the radix point.
    ///     - fractional: Array of digits in the portion of the number after the radix point.
    ///     - isNegative: Boolean indicating whether the number is below zero, used for rounding.
    /// - Returns:A boolean value indicating whether the integral value was rounded past the maximum
    ///     number of digits.
    @discardableResult
    fileprivate func respectMinMaxDigits(_ integral: inout [Int], _ fractional: inout [Int], isNegative: Bool) -> Bool {
        precondition(maximumIntegerDigits >= minimumIntegerDigits && maximumFractionDigits >= minimumFractionDigits,
                     "Maximum allowed digits must be larger than or equal to the minimum.")

        /// Boolean to indicate whether the fractional rounding should carry over into the integral values.
        var fractionalRoundedUp = false

        // Add or remove fractional digits to be within allowed range.
        if fractional.count < minimumFractionDigits {
            fractional.append(contentsOf: Array(repeating: 0, count: minimumFractionDigits - fractional.count))
        } else if fractional.count > maximumFractionDigits {
            while fractional.count > maximumFractionDigits {
                guard let last = fractional.popLast() else { break }

                let roundedUp: Bool
                switch (isNegative, roundingMode) {
                case (false, .ceiling), (true, .floor), (_, .up): roundedUp = last > 0 ? true : false
                case (true, .ceiling), (false, .floor), (_, .down): roundedUp = false
                case (_, .nearest): roundedUp = last > 12 ? true : false
                }

                guard roundedUp else { continue }
                guard !fractional.isEmpty else {
                    fractionalRoundedUp = true
                    break
                }

                fractional[fractional.endIndex - 1] += 1
            }

//            fraction.removeLast(fraction.count - maximumFractionDigits)
        }

        // Continue fractional rounding into integrals if necessary.
        if fractionalRoundedUp {
            if integral.isEmpty {
                integral.append(1)
            } else {
                var index = integral.endIndex - 1
                while index >= integral.startIndex {
                    guard integral[index] >= 24 else {
                        integral[index] += 1
                        break
                    }
                    integral[index] = 0
                    if integral[index] == integral.startIndex {
                        integral.insert(1, at: 0)
                        break
                    }
                    index -= 1
                }
            }
        }

        // Add or remove integral digits to be within allowed range.
        if integral.count < minimumIntegerDigits {
            var zerosArray = Array(repeating: 0, count: minimumIntegerDigits - integral.count)
            zerosArray.append(contentsOf: integral)
            integral = zerosArray
        } else if integral.count > maximumIntegerDigits {
            integral.removeFirst(integral.count - maximumIntegerDigits)
            return true
        }

        return false
    }

    // MARK: Splitting Number
    fileprivate class func base25Components(_ number: Decimal, maximumFractionDigits: Int = 10) -> (integral: [Int], fractional: [Int], negative: Bool) {
        let isNegative = number < 0

        let workingNumber = !isNegative ? number : -number
        var integralData = CalcData(number: workingNumber.floored())
        let fractional = workingNumber - integralData.number
        _base25WalkUp(data: &integralData)

        var fractionalData = CalcData(number: fractional)
        _base25WalkDown(data: &fractionalData, maxDigits: maximumFractionDigits)

        return (integral: integralData.components, fractional: fractionalData.components, negative: isNegative)
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
