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
        
        let res3 = ModularMath.divide(divider: 13, divisor: 77, modulo: 101)
        XCTAssert(res3 == 71)
        
        let res4 = ModularMath.exponentiate(13, 57, modulo: 101)
        XCTAssert(res4 == 45)

        let res5 = ModularMath.inverse(77, modulo: 101)
        XCTAssert(res5 == 21)
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
    
    func testMatrixIntersection() {
        var m0 = Matrix<Int>(rows: 9, columns: 7)
        m0.fill(value:1)
        print(m0)
        var m1 = Matrix<Int>(rows: 6, columns: 4)
        m1.fill(value:2)
        print(m1)
        let offset = Cell(row: 2, column: -1)
        let im = m0.intersection(offset: offset, otherMatrix: m1, transform:{($0 ?? 0) + ($1 ?? 0)})
        if let _ = Matrix<Int>.intersection(firstMatrix: &m0, secondMatrix: &m1, firstOffsetFromSecond:offset, transform: {(a, b) in (a ?? 0) + (b ?? 0)}) {
            print(m0)
        }
        XCTAssertNotNil(im)
        XCTAssertTrue(im?.rowSize == 6)
        XCTAssertTrue(im?.columnSize == 3)
    }
    func testMatrixMapping() {
        var m0 = Matrix<Int>(rows: 9, columns: 7)
        m0.fill(value:1)
        print(m0)
        let m1 = m0.map(){ (row,column,value) in
            return "[\(row),\(column)] = \(value?.description ?? "?")"
        }
        print(m1)
    }
    func testGrid() {
        var columns = [Column]()
        var first = Column(label:"1",width: 10, alignment: .Left)
        let space = "...."
        first.enhancer = StringWrapper()
        columns.append(first)
        columns.append(Column(label:"2", width: space.count))
        columns.append(Column(label:"3", width: 40, alignment: .Center))
        columns.append(Column(label:"4", width: 10, alignment: .Right))
        var grid = Grid(columns: columns)
        grid.headerSeparatorToken = Grid.EM_DASH
        grid.footerSeparatorToken = Grid.EM_DASH
        grid.addRow(row: ["A", space, "testje", "15"])
        grid.addRow(row: ["B1",space, "anders dan", "1"])
        grid.addRow(row: ["B2",space, "verveling is nog niet altijd het ergste wat je kan overkomen", "119"])
        grid.addRow(row: ["C", space, "warme windstroming", "35"])
        grid.addRow(row: ["D", space, "buro lamp", "5"])
        grid.write(printer: ConsolePrinter(prefix: "  "))

    }
    
    struct StringWrapper : StringEnhancer {
        func beforePadding(value: String, column: Column) -> String {
            return "*\(value)*"
        }
    }
    
    func testFileInfo(){
        let fileInfo1:FileInfo = ""
        XCTAssert(fileInfo1.path == nil)
        XCTAssert(fileInfo1.filename == "")
        XCTAssert(fileInfo1.fileext == nil)
        print("FileInfo1: \(fileInfo1)")
        
        let fileInfo2: FileInfo = "/"
        XCTAssert(fileInfo2.path == [""])
        XCTAssert(fileInfo2.filename == "")
        XCTAssert(fileInfo2.fileext == nil)
        print("FileInfo2: \(fileInfo2)")

        let fileInfo3: FileInfo = "/path/a.txt"
        XCTAssert(fileInfo3.path == ["","path"])
        XCTAssert(fileInfo3.filename == "a")
        XCTAssert(fileInfo3.fileext == "txt")
        print("FileInfo3: \(fileInfo3)")

        let fileInfo4: FileInfo = "path/a.txt"
        XCTAssert(fileInfo4.path == ["path"])
        XCTAssert(fileInfo4.filename == "a")
        XCTAssert(fileInfo4.fileext == "txt")
        print("FileInfo4: \(fileInfo4)")
    }
}
