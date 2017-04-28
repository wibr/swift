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
        for (i,prime) in Primes().enumerated() {
            print(prime)
            if i > 100 {
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
        let m:BigInt =   "382487367782920039376462636e81374382943174327688"
        print(m)
        let sum = n + m
        print(sum)
    }
    
    func process(combi:(BigInt,BigInt,BigInt,BigInt)){
        print("add: \(combi.0) + \(combi.1) = \(combi.0 + combi.1) - expected: \(combi.2)")
        print("sub: \(combi.0) - \(combi.1) = \(combi.0 - combi.1) - expected: \(combi.3)")
    }
    
    func testSubtract() {
        let p1 = BigInt(value:5)
        let p1_ = BigInt(value:-5)
        let p2 = BigInt(value:3)
        let zero = BigInt(value:0)
        let n1 = BigInt(value:-11)
        let n1_ = BigInt(value:11)
        let n2 = BigInt(value:-7)
        
        let d2 = BigInt(value:2)
        let d4_ = BigInt(value:-4)
        let d6 = BigInt(value:-6)
        let d8 = BigInt(value:8)
        let b16 = BigInt(value:16)
        let b16_ = BigInt(value:-16)
        let d18_ = BigInt(value:-18)
        
        var combies = [(BigInt, BigInt, BigInt, BigInt)]()
        combies.append((p1, n1, d6, b16))
        combies.append((p1, p2, d8, d2))
        combies.append((p1, zero, p1, p1))
        combies.append((zero, p1, p1, p1_))
        combies.append((zero, zero, zero, zero))
        combies.append((zero, n1, n1, n1_))
        combies.append((n1, p1, d6, b16_))
        combies.append((n1, zero, n1, n1))
        combies.append((n1, n2, d18_, d4_))
    
        for combi in combies {
            process(combi: combi)
        }
    }
    
    func testFactorize(){
        let f = 2
        let factors2 = Math.factorize(n: f)
        XCTAssert(factors2.first! == 2)
        let n = 738746463
        let factors = Math.factorize(n: n)
        print(factors)
    }
    
    func testMultiply() {
        //119 * 473 =
        let first = 13419
        let second = 45763
        let expected = first * second
        let n = BigInt(value:first)
        let m = BigInt(value:second)
        let p = n * m
        if let i = p.intValue {
            XCTAssert(i == expected)
        }
        else {
            XCTFail("Unable to convert \(p) to Int")
        }
        
    }
 
    func testKarasuba() {
        let a = 12345
        let b = 6789
        let c = Math.karatsuba(num1: a, num2: b)
        print ( c)
    }
}
