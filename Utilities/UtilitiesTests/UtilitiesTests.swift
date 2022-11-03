//
//  UtilitiesTests.swift
//  UtilitiesTests
//
//  Created by Chien, Arnold on 3/15/19.
//  Copyright © 2019 Chien, Arnold. All rights reserved.
//

import XCTest
@testable import Utilities

class UtilitiesTests: XCTestCase {
    let logFilePath: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]).appendingPathComponent("test.log")

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        //remove it if it exists (fail silently)
        try? FileManager.default.removeItem(at: logFilePath)
    }

    func testLogWarningSeverityLevel() {
        let log = Log(name: "TEST LOG")
        log.enable(withLevel: .warning, writeToFile: logFilePath, synchronous: true)
        log.debug("DEBUG message.  You shouldn't see me.")
        log.info("INFO message.  You shouldn't see me.")
        log.warning("WARNING message.  You should see me.")
        log.error("ERROR message.  You should see me.")
        guard FileManager.default.fileExists(atPath: logFilePath.path) else {
            XCTFail("Log file does not exist.")
            return
        }
        guard let fileData = FileManager.default.contents(atPath: logFilePath.path) else {
            XCTFail("Log file data does not exist.")
            return
        }
        guard let fileContents = String(data: fileData, encoding: .utf8) else {
            XCTFail("Log file data does not convert to a string.")
            return
        }
        XCTAssert(fileContents.contains("WARNING"), "Warning message was not logged.")
        XCTAssert(fileContents.contains("ERROR"), "Error message was not logged.")
        XCTAssertFalse(fileContents.contains("INFO"), "Info message was logged.")
        XCTAssertFalse(fileContents.contains("DEBUG"), "Debug message was logged.")
    }
}
