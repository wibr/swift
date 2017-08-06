//
//  WibrToolsTests.swift
//  WibrToolsTests
//
//  Created by Winfried Brinkhuis on 06-08-17.
//
@testable import WibrTools
import XCTest

class WibrToolsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUlamSpiralPosition() {
        let ulam = UlamSpiral()
        let number = 888
        let expectedPosition = (ring:31, x:-2, y:15)
        let calculatedPosition = ulam.calculatePosition(num: number)
        let corner  = UlamSpiral.isCorner((calculatedPosition.x,calculatedPosition.y))
        XCTAssertFalse(corner)
        XCTAssertEqual(calculatedPosition.ring, expectedPosition.ring)
        XCTAssertEqual(calculatedPosition.x, expectedPosition.x)
        XCTAssertEqual(calculatedPosition.y, expectedPosition.y)
    }
    
    func testUlamSumOfCorners() {
        let size = 5
        let nums = size * size
        let expectedSum = 101
        let actualSum = UlamSpiral().prefix(nums).filter{ abs($0.x) == abs($0.y) }.reduce(0) { $0 + $1.num }
        XCTAssertTrue(actualSum == expectedSum)
    }
    
}
