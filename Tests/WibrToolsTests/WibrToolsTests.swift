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
        let spiral = UlamSpiral()
        let actualSum = spiral.prefix(nums).filter{ abs($0.x) == abs($0.y) }.reduce(0) { (r, pir) -> Int in
            return r + spiral.calculateNumber(position:pir)
        }
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
    
    func testStatsData() {
        let dataSet1 = StatsData([3.0,4,5,6,7,8,9])
        let dataSet2 = StatsData([1,2.0])
        var sum = dataSet1.sum
        XCTAssertTrue(sum == 42)
        var avg = dataSet1.average
        XCTAssertTrue(avg == 6.0)
        var stdev = dataSet1.stdev
        XCTAssertTrue( stdev == 2.0)
        var count = dataSet1.count
        XCTAssertTrue(count == 7)
        
        let dataSetCombined = dataSet1 + dataSet2
        
        stdev = dataSetCombined.stdev
        let ok = stdev.withinRange(other: 2.58, delta: 0.01)
        XCTAssertTrue(ok)
        sum = dataSetCombined.sum
        XCTAssertTrue(sum == 45.0)
        avg = dataSetCombined.average
        XCTAssertTrue(avg == 5.0)
        count = dataSetCombined.count
        XCTAssertTrue(count == 9)
    }
    
    func testGrid() {
        var columns = [Column]()
        var first = Column(width: 10, alignment: .Left)
        let space = "...."
        first.enhancer = StringWrapper()
        columns.append(first)
        columns.append(Column(width: 6))
        columns.append(Column(width: 30, alignment: .Center))
        columns.append(Column(width: 20, alignment: .Right))
        var grid = Grid(columns: columns)
        grid.headerSeparatorToken = Grid.EM_DASH
        grid.footerSeparatorToken = Grid.EM_DASH
        grid.addRow(row: ["A", space, "testje", "15"])
        grid.addRow(row: ["B1",space, "anders dan", "1"])
        grid.addRow(row: ["B2",space, "verveling", "119"])
        grid.addRow(row: ["C", space, "warme windstroming", "35"])
        grid.addRow(row: ["D", space, "buro lamp", "5"])
        grid.write(printer: ConsolePrinter())

    }
    
    struct StringWrapper : StringEnhancer {
        func beforePadding(value: String, alignment: Alignment?) -> String {
            return "*\(value)*"
        }
    }
}
