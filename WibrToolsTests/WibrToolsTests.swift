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
    
    func testMatrix() {
        let rows = 3
        let columns = 4
        var matrix = Matrix<Int>(rows: rows, columns: columns)
        for row in 0 ..< rows {
            for col in 0 ..< columns {
                matrix[row,col] = (row+1) * (col+1)
            }
        }
        print( matrix )
        for row in 1..<rows-1 {
            for col in 1..<columns-1 {
                let sub = matrix.adjacent(to: (row,col))
                let prod = sub.flatMap{sub[$0]}.reduce(1){$0*$1}
                print("\(sub) : \(prod)")
            }
        }
        
        let values = [[2,3,4,5],[4,3,5,2],[3,4,2,5]]
        let vm = Matrix<Int>(values:values)
        print(vm)

        
        for c in matrix {
            print(matrix[c]!)
        }
        
        let cell = (row:0, column:0)
        let submatrix = matrix.adjacent(to: cell)
        print(submatrix)
        
        let product = matrix.flatMap({matrix[$0]}).reduce(1,{$0*$1})
        print(product)
    }
    
    func testBigInt() {
        let n:BigInt = "-9933893923746842983483838399337123128371329633456"
        print(n)
        let m:BigInt = "382487367782920039376462636e81374382943174327688"
        print(m)
        let sum = n + m
        print(sum)
        
    }
    
    func testSubtract() {
        let n2:BigInt = 10000
        let n1:BigInt = 9999
        let diff = n1 - n2
        print("\(n1) - \(n2) = \(diff)")
        
        print("\(n1 <> n2)")
        
        for n in stride(from:-3,to:6,by:4){
            let f = BigInt(value:n)
            for m in stride(from: -7, to: 4, by: 5){
                let s = BigInt(value:m)
                print("\(f) + \(s) = \(f + s)")
                print("\(f) - \(s) = \(f - s)")
                
            }
        }
    }
    
}
