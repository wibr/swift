//
//  StatsData.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 10-03-18.
//

import Foundation

public class StatsData : CustomStringConvertible{
    var _count: Int
    var _avg: Double
    var _stdev: Double
    var _sum: Double
    
    public init(_ values:[Double]){
        self._count = values.count
        self._sum = StatsData.calcSum(values)
        self._avg = self._sum / Double(self._count)
        self._stdev = StatsData.calcStDev(self._avg, values)
    }
    
    public init(count: Int, avg: Double, stdev:Double) {
        self._count = count
        self._avg = avg
        self._sum = avg * Double(count)
        self._stdev = stdev
    }
    
    public var count : Int {
        return _count
    }
    
    public var average : Double {
        return _avg
    }
    
    public var stdev : Double {
        return _stdev
    }
    
    public var sum : Double {
        return _sum
    }
    /**
     * Merges this instance with the given StatsData.
     * Calculates the new values of count, average and standard deviation
     * returns a new StatsData instance.
     *
     * @param other the StatsData to merge with
     * @return a new merged instance.
     */
    public func merge(other: StatsData) -> StatsData {
        let n = self.count + other.count
        let m = self.calcAverage(other)
        let s = self.calcStDev(other)
        return StatsData(count: n, avg: m, stdev: s)
    }
    
    public func add(values: [Double]) -> StatsData{
        return self.merge(other: StatsData(values))
    }
    
    private func sumOfSquares() -> Double {
        let a = self.stdev * self.stdev
        let b = self.average * self.average
        return Double(count) * (a + b)
    }
    
    private func sumOfSquares(_ data:StatsData) -> Double {
        let a = self.sumOfSquares()
        let b = data.sumOfSquares()
        let c = count + data.count
        return Double(c) * (a + b)
    }
    
    private func squareOfSum(_ group:StatsData) -> Double {
        let d = self.sum + group.sum
        return d * d
    }
    
    private func countSquare(_ group: StatsData) -> Int{
        let total = self.count + group.count
        return total * total
    }
    
    private func calcAverage(_ group: StatsData) -> Double {
        return (self.sum + group.sum) / Double(self.count + group.count)
    }
    
    private func calcStDev(_ data: StatsData) -> Double {
        let f = self.sumOfSquares(data)
        let g = self.squareOfSum(data)
        let h = self.countSquare(data)
        let q = (f - g) / Double(h)
        return √q
    }
    
    private static func calcStDev(_ avg: Double, _ values: [Double] ) -> Double {
        var sumOfSquares = 0.0
        for d in values {
            let diff = d - avg;
            sumOfSquares += diff * diff
        }
        return √(sumOfSquares / Double(values.count))
    }
    
    private static func calcSum(_ values: [Double] ) -> Double{
        return values.reduce(0.0, +)
    }
    
    public var description: String{
        return "count: \(self.count), sum: \(self.sum), average: \(self.average), stdev: \(self.stdev)"
    }
}

extension StatsData : Equatable {
    public static func == (lhs: StatsData, rhs: StatsData) -> Bool {
        return lhs._count == rhs._count && lhs._sum == rhs._sum && lhs._avg == rhs._avg && lhs._stdev.withinRange(other: rhs._stdev, delta: 0.0000001)
    }
    
    public static func + (lhs:StatsData, rhs:StatsData) -> StatsData {
        return lhs.merge(other: rhs)
    }
}


