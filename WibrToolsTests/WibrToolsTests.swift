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
        let expectedPosition = PositionInRing(31, -2, 15)
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
    
    func testBigIntPower() {
        var numbers = Set<BigInt>()
        for a in 2...5 {
            for b in 2...5 {
                numbers.insert(BigInt(int:a).power(b))
            }
        }
        for number in numbers.sorted() {
            print(number)
        }
    }
    
    func testBase10() {
        let a10 = 345
        let a2 = Math.toBase(number: a10, base: 2)
        let b10 = Math.fromBase(number: a2, base: 2)
        XCTAssert(b10 == a10)
    }
    
    func testSieveOfAtkin(){
        let primes = Primes()
        let results = primes.sieveOfAtkin(max: 10000)
        print(results)
    }
    
    func testFileWalker(){
        let walker = FileWalker(rootDir: ".")
        walker.collecFiles(all:true) { (name, type) in
            print("\(type) : \(name)")
        }
    }
    
    func testMatrixProduct() {
        
        let f: [[Double]] = [
            [1,2,3],
            [4,5,6]
        ]
        let s:[[Double]] = [
            [-1,-2],
            [-3,-4],
            [-5,-6]
        ]

        let first = Matrix<Double>(values:f)
        let second = Matrix<Double>(values:s)
        
        let p1 = first.product(matrix:second)
        print(p1)
        let p2 = second.product(matrix:first)
        print(p2)

    }
    
    func testModularMath() {
        let a = 53
        let b = 37
        let modulo = 17
        let expected1 = (a * b) % modulo
        let res1 = ModularMath.multiply(a, b, modulo: modulo)
        XCTAssert(res1 == expected1)
        
        
        let k = 77
        let l = 13
        let p = 101
        let expected2 = 37
        
        let res2 = ModularMath.divide(divider: k, divisor: l, modulo: p)
        XCTAssert(res2 == expected2)
        print(res2)
        
    }
}
