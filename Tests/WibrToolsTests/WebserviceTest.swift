//
//  WebserviceTest.swift
//  WibrToolsTest
//
//  Created by Winfried Brinkhuis on 25-03-18.
//
@testable import WibrTools
import XCTest

struct Script : Codable {
    let name : String
    init(name: String) {
        self.name = name
    }
}

struct Message : Error, Codable {
    let type: String
    let code: String
    
    init(type: String, code: String){
        self.type = type
        self.code = code
    }
    
    init?(dict:Any){
        guard let d = dict as? [String:Any] else {
            return nil
        }
        self.type = d["type"] as! String
        self.code = d["code"] as! String
    }
}



class WebserviceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWebservice() {
//        let baseUrl = "http://localhost:3000/api/v1/conversation"
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
