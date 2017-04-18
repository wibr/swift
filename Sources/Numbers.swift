//
//  Numbers.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 16-04-17.
//
//

import Foundation

public enum Sign : String {
    case positive = "+"
    case negative = "-"
    
    static func from(value:Int) -> Sign? {
        return value > 0 ? .positive : (value < 0 ? .negative : nil)
    }
    
    func flip() -> Sign {
        switch self {
            case .positive : return .negative
            case .negative : return .positive
        }
    }
}

typealias BigIntOperation = ((BigInt,BigInt) -> BigInt)

public struct BigInt : CustomStringConvertible {
    
    static var addScheme = Matrix<BigIntOperation>(rows:3, columns:3)
    static var subtractScheme = Matrix<BigIntOperation>(rows:3, columns:3)
    
    fileprivate var values:[Int]
    var sign:Sign?
    
    var length: Int {
        return values.count
    }
    
    private var schemeIndex:Int {
        if let s = self.sign {
            return s == .positive ? 0 : 2
        }
        return 1
    }
    
    public init(values: [Int], sign:Sign? = .positive){
        var array = values.map{$0 % 10}
        while let value = array.first, value == 0 {
            array.removeFirst()
        }
        if let s = sign {
            self.sign = s
        }
        if array[0] == 0 {
            self.sign = .none
        }
        self.values = array.reversed()
    }
    
    public init(string:String){
        var s = string
        var sgn:Sign?
        if let idx = s.characters.index(of:"-"), idx == s.startIndex {
            let fromIndex = s.characters.index(after: idx)
            s = s[fromIndex ..< s.endIndex]
            sgn = .negative
        }
        let array = s.characters.flatMap{Int(String($0))}
        if let first = array.first, first == 0 {
            sgn = .none
        }
        else if sgn == nil {
            sgn = .positive
        }
        self.init(values:array, sign:sgn)
    }
    
    public init(value:Int){
        self.values = [Int]()
        self.sign = Sign.from(value: value)
        var v = abs(value)
        repeat {
            self.values.append(v % 10)
            v = v / 10
        } while v > 0
    }
    
    private init(){
        self.values = [Int]()
        self.sign = .none
    }
    
    public mutating func negated() -> BigInt {
        if let s = self.sign {
            self.sign = s.flip()
        }
        return self
    }
    
    public func add(_ other:BigInt) -> BigInt {
        
        
        if self.negative && other.negative {
            var result = self.sum(first: self, second: other)
            return result.negated()
        }
        if self.negative && !other.negative {
            let c = self <> other
            if c == 0 {
                return BigInt(value:0)
            }
            var result = self.diff(first: )
        }
        if XOR(self.negative, other.negative) {
            var result = self < other ? self.diff(first: other, second: self) : self.diff(first: self, second: other)
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
    
    fileprivate func sum(first: BigInt, second:BigInt) -> BigInt {
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
    
    fileprivate func diff(big:BigInt, small: BigInt) -> BigInt {
        var values = [Int]()
        var borrow = false
        let smallLength = small.length
        var index = 0
        for var lval in big.values {
            if index < smallLength {
                let sval = small.values[index]
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
        return BigInt(values:values)
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
        let token = (self.sign == .none)  ? "" : self.sign!.rawValue
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
        let c = lhs <> rhs
        return  c < 0
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

extension BigInt {
    func p_add_p(first:BigInt,second:BigInt) ->BigInt {
        var result = sum(first:first,second:second)
        result.sign = .positive
        return result
    }
    
    func n_add_n(first:BigInt,second:BigInt) -> BigInt {
        var result = sum(first:first,second:second)
        result.sign = .negative
        return result
    }

    func z_add_p(first:BigInt,second:BigInt) -> BigInt {
        return second
    }

    func z_add_n(first:BigInt,second:BigInt) -> BigInt {
        return second
    }
    
    func z_add_z(first:BigInt,second:BigInt) -> BigInt {
        return second
    }
    func z_add(first:BigInt,second:BigInt) -> BigInt {
        return second
    }
    
    func n_add_z(first:BigInt,second:BigInt) -> BigInt {
        return first
    }

    func p_add_n(first:BigInt,second:BigInt) -> BigInt {
        var big = first
        var small = second
        var sign = Sign.positive
        if first < second {
            big = second
            small = first
            sign = Sign.negative
        }
        var result = diff(big: big, small: small)
        result.sign = sign
        return result
    }
    
    func n_add_p(first:BigInt,second:BigInt) -> BigInt {
        var big = first
        var small = second
        var sign = Sign.negative
        if first < second {
            big = second
            small = first
            sign = Sign.positive
        }
        var result = diff(big: big, small: small)
        result.sign = sign
        return result
    }
    
    // 6 - 4 or 6 - 7
    func p_substract_p(first:BigInt,second:BigInt) -> BigInt {
        let ordered = order(first,second)
        var result = diff(first:first,second:second)
        result.sign = .negative
        return result
    }

    // -6 - +4
    func n_substract_p(first:BigInt,second:BigInt) -> BigInt {
        var result = sum(first:first,second:second)
        result.sign = .negative
        return result
    }
    
    
    func order(_ first: BigInt, _ second: BigInt) -> (BigInt,BigInt,Bool?) {
        if first > second {
            return (first,second, false)
        }
        if second > first {
            return (second, first, true)
        }
        return (first, first, .none)
    }
}
