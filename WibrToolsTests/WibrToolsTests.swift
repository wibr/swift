//
//  WibrToolsTests.swift
//  WibrToolsTests
//
//  Created by winfried brinkhuis on 26-02-17.
//
//

import XCTest
@testable import WibrTools

class WibrToolsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        Logger.log(condition:true, message: "Dit is een test")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPrimesGenerator() {
        for prime in Primes() {
            print(prime)
            if prime > 100 {
                return
            }
        }

    }
    
}
