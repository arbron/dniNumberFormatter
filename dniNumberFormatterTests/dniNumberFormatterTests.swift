//
//  dniNumberFormatterTests.swift
//  dniNumberFormatterTests
//
//  Created by Jeff Hitchcock on 2019-09-14.
//  Copyright © 2019 Jeff Hitchcock. All rights reserved.
//

import XCTest
@testable import dniNumberFormatter

class dniNumberFormatterTests: XCTestCase {
    func testBasicStringFormatting() {
        let formatter = DniNumberFormatter()
        XCTAssertEqual(formatter.string(forNumber: 2.12), "2.3")
        XCTAssertEqual(formatter.string(forNumber: 15), "%")
        XCTAssertEqual(formatter.string(forNumber: 625), "100")
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
}
