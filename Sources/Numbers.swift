//
//  Numbers.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 16-04-17.
//
//

import Foundation


public struct BigInt : CustomStringConvertible {
    fileprivate var values:[Int]
    var negative = false
    
    var length: Int {
        return values.count
    }
    
    public init(values: [Int], negative:Bool = false){
        var array = values.map{$0 % 10}
        while let value = array.first, value == 0 {
            array.removeFirst()
        }
        self.negative = negative
        self.values = array.reversed()
    }
    
    public init(string:String){
        var s = string
        var ltz = false
        if let idx = s.characters.index(of:"-"), idx == s.startIndex {
            let fromIndex = s.characters.index(after: idx)
            s = s[fromIndex ..< s.endIndex]
            ltz = true
        }
        let array = s.characters.flatMap{Int(String($0))}
        self.init(values:array)
        self.negative = ltz
    }
    
    public init(value:Int){
        self.values = [Int]()
        self.negative = false
        var v = value
        if v < 0 {
            v = v * -1
            self.negative = true
        }
        repeat {
            self.values.append(v % 10)
            v = v / 10
        } while v > 0
    }
    
    private init(){
        self.values = [Int]()
        self.negative = false
    }
    
    public mutating func negated() -> BigInt {
        self.negative = !self.negative
        return self
    }
    
    public func add(_ other:BigInt) -> BigInt {
        if XOR(self.negative, other.negative) {
            var result = self.diff(first:self, second:other)
            return result.negated()
        }
        return self.sum(first:self, second: other)
    }
    
    public func subtract(_ other: BigInt) -> BigInt {
        if self.equals(other) {
            return BigInt(value:0)
        }
        if XOR(self.negative, other.negative){
            var result = self.sum(first:self, second:other)
            return result.negated()
        }
        return self.diff(first:self, second:other)
    }
    
    private func sum(first: BigInt, second:BigInt) -> BigInt {
        var values = [Int]()
        var remainder = false
        var index = 0
        let count = first.length
        for var num in second.values {
            if index < count {
                num += first.values[index]
            }
            let next = addNum(num: num, remainder: &remainder)
            values.append(next)
            index += 1
        }
        if index < count {
            for i in index..<count {
                let num = first.values[i]
                let next = addNum(num: num, remainder: &remainder)
                values.append(next)
            }
        }
        if remainder {
            values.append(1)
        }
        return BigInt(values:values)
    }
    
    private func diff(first:BigInt, second: BigInt) -> BigInt {
        var largest = first
        var smallest = second
        var lessThanZero = false
        if largest.compare(smallest) < 0 {
            lessThanZero = true
            largest = second
            smallest = first
        }
        var values = [Int]()
        var borrow = false
        let smallestLength = smallest.length
        var index = 0
        for var lval in largest.values {
            if index < smallestLength {
                let sval = smallest.values[index]
                if borrow {
                   lval -= 1
                }
                var nv = lval - sval
                if nv < 0 {
                    borrow = true
                    nv = (lval+10) - sval
                }
                else {
                    borrow = false
                }
                values.append(nv)
            }
            else {
                var nv = lval
                if borrow {
                    nv = lval - 1
                }
                if nv < 0 {
                    nv += 10
                    borrow = true
                }
                values.append(nv)
            }
            index += 1
        }
        while let value = values.last, value == 0 {
            values.removeLast()
        }
        return BigInt(values:values, negative:lessThanZero)
    }
    
    private func addNum(num: Int, remainder:inout Bool) -> Int {
        var result = num
        if remainder { result += 1 }
        if  result >= 10 {
            remainder = true
            return result % 10
        }
        remainder = false
        return result
    }
    
    public var description: String {
        let token = negative ? "-" : ""
        return token + self.values.reversed().map({String.init(describing:$0)}).joined()
    }
}

infix operator <>

extension BigInt : Comparable{
    public func equals(_ other:BigInt) -> Bool{
        if self.values.count != other.values.count {
            return false
        }
        let thisValues = self.values
        let otherValues = other.values
        for (index,thisValue) in thisValues.enumerated() {
            if thisValue != otherValues[index] {
                return false
            }
        }
        return true
    }
    
    public func compare(_ other:BigInt) -> Int{
        if self.values.count > other.values.count {
            return 1
        }
        if self.values.count < other.values.count {
            return -1
        }
        let thisReversed = self.values.reversed()
        let otherReversed = Array(other.values.reversed())
        for (index,thisValue) in thisReversed.enumerated() {
            let otherValue = otherReversed[index]
            if thisValue > otherValue {
                return 1
            }
            if thisValue < otherValue {
                return -1
            }
        }
        return 0
    }

    public static func + (lhs:BigInt,rhs:BigInt) -> BigInt {
        return lhs.add(rhs)
    }
    
    public static func - (lhs:BigInt,rhs:BigInt) -> BigInt {
        return lhs.subtract(rhs)
    }

    public static prefix func - (number: BigInt) -> BigInt {
        var n = number
        return n.negated()
    }
    
    public static func == (lhs:BigInt, rhs:BigInt) -> Bool {
        return lhs.equals(rhs)
    }
    
    
    public static func <> (lhs:BigInt, rhs:BigInt) -> Int {
        return lhs.compare(rhs)
    }

    public static func < (lhs:BigInt, rhs:BigInt) -> Bool {
        return (lhs <> rhs) < 0
    }
    
    public static func > (lhs:BigInt, rhs:BigInt) -> Bool {
        return (lhs <> rhs) > 0
    }
    
}

extension BigInt : ExpressibleByStringLiteral {
    public init(stringLiteral value: String ){
        self = BigInt(string:value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        self = BigInt(stringLiteral: value)
    }
    
    public init(unicodeScalarLiteral value: String){
        self = BigInt(stringLiteral: value)
    }
}

extension BigInt : ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int){
        self = BigInt(value:value)
    }
}
