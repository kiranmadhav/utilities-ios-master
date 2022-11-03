//
//  WebServerTests.swift
//  UtilitiesTests
//
//  Created by Brooks, Jon on 11/13/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//

import XCTest
@testable import Utilities

class WebServerTests: XCTestCase {
    let resourcesBaseURL = Bundle.module.bundleURL
    let testFileRelativePath = "PackageResources/test.html"

    func testResourcesCDN() {
        XCTAssertNotNil(WebServer.resourcesCDN)
    }

    func testServesContent() {
        let server = WebServer(baseDirectory: resourcesBaseURL)

        let url = server.baseServerURL!.appendingPathComponent(testFileRelativePath)
        let expectation = self.expectation(description: "test")

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            XCTAssertEqual(
                String(data: data!, encoding: .utf8),
                "<html><head></head><body>Hello world!</body></html>\n"
            )
            expectation.fulfill()
        }

        task.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPauseNewServer() {
        let server = WebServer(baseDirectory: resourcesBaseURL)

        XCTAssertTrue(server.serverIsRunning)
        server.pauseServer()
        XCTAssertFalse(server.serverIsRunning)
        XCTAssertNoThrow(try server.restartServer())
        XCTAssertTrue(server.serverIsRunning)
    }

}
