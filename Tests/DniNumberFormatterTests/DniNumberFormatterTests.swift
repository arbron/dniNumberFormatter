//
//  dniNumberFormatterTests.swift
//  dniNumberFormatterTests
//
//  Created by Jeff Hitchcock on 2019-09-14.
//  Copyright © 2019 Jeff Hitchcock. All rights reserved.
//

import XCTest
@testable import DniNumberFormatter

class dniNumberFormatterTests: XCTestCase {
    func testBasicStringFormatting() {
        let formatter = DniNumberFormatter()
        XCTAssertEqual(formatter.string(forNumber: 2.12), "2.3")
        XCTAssertEqual(formatter.string(forNumber: 15), "%")
        XCTAssertEqual(formatter.string(forNumber: 625), "100")
    }

    func testNegativeFormatting() {
        let formatter = DniNumberFormatter()
        XCTAssertEqual(formatter.string(forNumber: -1), "−1")
    }

    func testMinAndMaxDigits() {
        let formatter = DniNumberFormatter()
        XCTAssertEqual(formatter.string(forNumber: 723.456), "13{.!)")
        formatter.maximumIntegerDigits = 2
        formatter.maximumFractionDigits = 1
        XCTAssertEqual(formatter.string(forNumber: 723.456), "3{.!")
        formatter.maximumIntegerDigits = 42
        formatter.maximumFractionDigits = 10
        formatter.minimumIntegerDigits = 5
        formatter.minimumFractionDigits = 5
        XCTAssertEqual(formatter.string(forNumber: 723.456), "0013{.!)000")
    }

    func testRoundingModes() {
        let formatter = DniNumberFormatter()

        // MARK: Fractional Rounding Rounding
        formatter.maximumFractionDigits = 1

        formatter.roundingMode = .nearest
        XCTAssertEqual(formatter.string(forNumber: 0.632), "0.^")
        XCTAssertEqual(formatter.string(forNumber: 0.616), "0.%")

        formatter.roundingMode = .ceiling
        XCTAssertEqual(formatter.string(forNumber: 0.632), "0.^")

        formatter.roundingMode = .up
        XCTAssertEqual(formatter.string(forNumber: 0.632), "0.^")

        formatter.roundingMode = .floor
        XCTAssertEqual(formatter.string(forNumber: 0.632), "0.%")

        formatter.roundingMode = .down
        XCTAssertEqual(formatter.string(forNumber: 0.632), "0.%")

        formatter.roundingMode = .nearest
        XCTAssertEqual(formatter.string(forNumber: -0.632), "−0.^")
        XCTAssertEqual(formatter.string(forNumber: -0.616), "−0.%")

        formatter.roundingMode = .ceiling
        XCTAssertEqual(formatter.string(forNumber: -0.632), "−0.%")

        formatter.roundingMode = .up
        XCTAssertEqual(formatter.string(forNumber: -0.632), "−0.^")

        formatter.roundingMode = .floor
        XCTAssertEqual(formatter.string(forNumber: -0.632), "−0.^")

        formatter.roundingMode = .down
        XCTAssertEqual(formatter.string(forNumber: -0.632), "−0.%")

        // MARK: Integer Rounding
        formatter.maximumFractionDigits = 0

        formatter.roundingMode = .nearest
        XCTAssertEqual(formatter.string(forNumber: 0.9), "1")
        XCTAssertEqual(formatter.string(forNumber: 0.2), "0")

        formatter.roundingMode = .ceiling
        XCTAssertEqual(formatter.string(forNumber: 0.9), "1")

        formatter.roundingMode = .up
        XCTAssertEqual(formatter.string(forNumber: 0.9), "1")

        formatter.roundingMode = .floor
        XCTAssertEqual(formatter.string(forNumber: 0.9), "0")

        formatter.roundingMode = .down
        XCTAssertEqual(formatter.string(forNumber: 0.9), "0")

        formatter.roundingMode = .nearest
        XCTAssertEqual(formatter.string(forNumber: -0.9), "−1")
        XCTAssertEqual(formatter.string(forNumber: -0.2), "0")

        formatter.roundingMode = .ceiling
        XCTAssertEqual(formatter.string(forNumber: -0.9), "0")

        formatter.roundingMode = .up
        XCTAssertEqual(formatter.string(forNumber: -0.9), "−1")

        formatter.roundingMode = .floor
        XCTAssertEqual(formatter.string(forNumber: -0.9), "−1")

        formatter.roundingMode = .down
        XCTAssertEqual(formatter.string(forNumber: -0.9), "0")

        formatter.roundingMode = .ceiling
        XCTAssertEqual(formatter.string(forNumber: 24.616), "10")
        formatter.maximumIntegerDigits = 1
        XCTAssertEqual(formatter.string(forNumber: 24.616), "0")
    }

    static var allTests = [
        ("testBasicStringFormatting", testBasicStringFormatting),
        ("testNegativeFormatting", testNegativeFormatting),
        ("testMinAndMaxDigits", testMinAndMaxDigits),
        ("testRoundingModes", testRoundingModes),
    ]
}
