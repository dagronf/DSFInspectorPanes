//
//  DSFInspectorPanesTests.swift
//  DSFInspectorPanesTests
//
//  Created by Darren Ford on 12/6/19.
//  Copyright © 2023 Darren Ford. All rights reserved.
//

import XCTest
@testable import DSFInspectorPanes

class DSFInspectorPanesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		var arr = [1, 2, 3, 4]
		arr.move(from: 1, to: 2)
		XCTAssertEqual(arr, [1, 3, 2, 4])

		arr = [1, 2, 3, 4]
		arr.move(from: 0, to: 3)
		XCTAssertEqual(arr, [2, 3, 4, 1])

		arr = [1, 2, 3, 4]
		arr.move(from: 3, to: 0)
		XCTAssertEqual(arr, [4, 1, 2, 3])
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
