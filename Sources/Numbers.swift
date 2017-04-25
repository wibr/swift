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
    
    var opposite : Sign {
        switch self {
            case .positive : return .negative
            case .negative : return .positive
        }
    }
    
}

typealias BigIntOperation = ((BigInt,BigInt) -> BigInt)

public struct BigInt : CustomStringConvertible {
    
    static var Helper = BigIntHelper()
    
    fileprivate var values:[Int]
    var sign:Sign?
    
    var length: Int {
        return values.count
    }
    
    fileprivate var schemeIndex:Int {
        if let s = self.sign {
            return s == .positive ? 0 : 2
        }
        return 1
    }
    
    public init(values: [Int], sign:Sign? = .positive){
        var array = values.map{$0 % 10}
        if array.count > 1 {
            while let value = array.first, value == 0 {
                array.removeFirst()
            }
        }
        if let s = sign {
            self.sign = s
        }
        if let first = array.first, first == 0 {
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
    
    fileprivate init(){
        self.values = [Int]()
        self.sign = .none
    }
    
    public static func Zero() -> BigInt {
        return BigInt(value:0)
    }
    
    public var isZero : Bool {
        return self.values.count == 1 && self.values.first == 0 && self.sign == nil
    }
    
    public var isOne : Bool {
        return self.values.count == 1 && self.values.first == 1
    }
    
    public mutating func negated() -> BigInt {
        if let s = self.sign {
            self.sign = s.opposite
        }
        return self
    }
    
    public func add(_ other:BigInt) -> BigInt {
        return BigInt.Helper.getAddOperation(self.schemeIndex,other.schemeIndex)(self,other)
    }
    
    public func subtract(_ other: BigInt) -> BigInt {
        return BigInt.Helper.getSubtractOperation(self.schemeIndex,other.schemeIndex)(self,other)
    }
    
    public var intValue: Int? {
        let str = self.values.reversed().reduce(""){$0+String($1)}
        return Int(str)
    }
    
    //   34
    //   73
    //  102
    // 2380
    // ────
    // 2482
    public func multiply(_ other: BigInt) -> BigInt {
        if self.isZero || other.isZero {
            return BigInt.Zero()
        }
        if self.isOne {
            return other
        }
        if other.isOne {
            return self
        }
        return BigInt.Helper.multiply(self, other)
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
        var result = compareSign(other)
        if result == 0 {
            result = compareValue(other)
        }
        return result
    }
    
    fileprivate func compareSign(_ other:BigInt) -> Int {
        // positive = 0, zero = 1, negative = 2 => positive = 1, zero = 0, negative = -1
        let n0 = (self.schemeIndex - 1) * -1
        let n1 = (other.schemeIndex - 1) * -1
        return n0 - n1
    }

    fileprivate func compareValue(_ other:BigInt) -> Int{
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
    
    public static func * (lhs:BigInt, rhs:BigInt) -> BigInt {
        return lhs.multiply(rhs)
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

struct BigIntHelper {
    
    var addScheme = Matrix<BigIntOperation>(rows:3, columns:3)
    var subtractScheme = Matrix<BigIntOperation>(rows:3, columns:3)
    
    init() {
        addScheme[0,0] = p_add_p
        addScheme[0,1] = any_operation_z
        addScheme[0,2] = p_add_n
        addScheme[1,0] = z_add_any
        addScheme[1,1] = z_add_any
        addScheme[1,2] = z_add_any
        addScheme[2,0] = n_add_p
        addScheme[2,1] = any_operation_z
        addScheme[2,2] = n_add_n
        
        subtractScheme[0,0] = p_subtract_p
        subtractScheme[0,1] = any_operation_z
        subtractScheme[0,2] = p_subtract_n
        subtractScheme[1,0] = z_subtract_p
        subtractScheme[1,1] = z_subtract_z
        subtractScheme[1,2] = z_subtract_n
        subtractScheme[2,0] = n_subtract_p
        subtractScheme[2,1] = any_operation_z
        subtractScheme[2,2] = n_subtract_n
    }
    
    func getAddOperation(_ row:Int, _ col:Int ) -> BigIntOperation{
        return self.addScheme[row,col]!
    }
    
    func getSubtractOperation(_ row:Int, _ col:Int ) -> BigIntOperation{
        return self.subtractScheme[row,col]!
    }
    
    fileprivate func sum(first: BigInt, second:BigInt) -> BigInt {
        var bi = BigInt()
        bi.values = _sum(first:first.values, second:second.values)
        return bi
    }

    fileprivate func _sum(first: [Int], second:[Int]) -> [Int] {
        var remainder = false
        var index = 0
        let count = first.count
        var result = [Int]()
        for var num in second {
            if index < count {
                num += first[index]
            }
            let next = addNum(num: num, remainder: &remainder)
            result.append(next)
            index += 1
        }
        if index < count {
            for i in index..<count {
                let num = first[i]
                let next = addNum(num: num, remainder: &remainder)
                result.append(next)
            }
        }
        if remainder {
            result.append(1)
        }
        return result
    }

    fileprivate func diff(big:BigInt, small: BigInt) -> BigInt {
        var result = BigInt()
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
                result.values.append(nv)
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
                result.values.append(nv)
            }
            index += 1
        }
        while let value = result.values.last, value == 0 {
            result.values.removeLast()
        }
        return result
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
    
    //    5 + 6 = +11
    func p_add_p(first:BigInt,second:BigInt) ->BigInt {
        return a_add_a(first: first, second: second, sign: .positive)
    }
    
    // -5 + -6 = -11
    func n_add_n(first:BigInt,second:BigInt) -> BigInt {
        return a_add_a(first: first, second: second, sign: .negative)
    }
    
    func a_add_a(first:BigInt,second:BigInt, sign:Sign) -> BigInt {
        var result = sum(first:first,second:second)
        result.sign = sign
        return result
    }
    
    // 0 +  5 = +5
    // 0 + -5 = -5
    // 0 +  0 =  0
    
    // 0 +  a = a
    func z_add_any(first:BigInt,second:BigInt) -> BigInt {
        return second
    }
    
    // -5 + 0 = -5
    //  5 + 0 = +5
    //  6 - 0 = +6
    // -6 - 0 = -6
    func any_operation_z(first:BigInt, second:BigInt) -> BigInt {
        return first
    }

    // 5 + -6 = -1  |  6 + -5 = +1
    func p_add_n(first:BigInt,second:BigInt) -> BigInt {
        return a_diff_b(first: first, second: second, initial: .positive)
    }

    // 6 - 4 = +2  | 4 - 6 = -2
    func p_subtract_p(first:BigInt,second:BigInt) -> BigInt {
        return a_diff_b(first: first, second: second, initial: .positive)
    }

    // -5 + 6 = +1 |  -6 + 5 = -1
    func n_add_p(first:BigInt,second:BigInt) -> BigInt {
        return a_diff_b(first: first, second: second, initial: .negative)
    }
    
    // -5 - -8 = +3  | -8 - -5 = -3
    func n_subtract_n(first:BigInt, second:BigInt) -> BigInt {
        return a_diff_b(first: first, second: second, initial: .negative)
    }
    
    func a_diff_b(first:BigInt, second:BigInt, initial:Sign) -> BigInt {
        var sign = initial
        let p = prepare(first, second)
        if p.compareResult == -1 {
            sign = sign.opposite
        }
        var result = diff(big:p.big, small:p.small)
        result.sign = sign
        return result
    }

    //  6 - -4 = +10  |
    func p_subtract_n(first:BigInt,second:BigInt) -> BigInt {
        return a_sum_b(first: first, second: second, sign: .positive)
    }

    // -6 - 4 = -10
    func n_subtract_p(first:BigInt,second:BigInt) -> BigInt {
        return a_sum_b(first: first, second: second, sign: .negative)
    }
    
    func a_sum_b(first:BigInt, second:BigInt, sign:Sign) -> BigInt {
        var result = sum(first:first,second:second)
        result.sign = sign
        return result
    }
    
    // 0 - a = -a
    func z_subtract_p(first:BigInt, second:BigInt) -> BigInt {
        return z_subtract_any(first: first, second: second, sign: .negative)
    }
    // 0 - -a = +a
    func z_subtract_n(first:BigInt, second:BigInt) -> BigInt {
        return z_subtract_any(first: first, second: second, sign: .positive)
    }
    
    // 0 - 0 = 0
    func z_subtract_z(first:BigInt, second:BigInt) -> BigInt {
        return z_subtract_any(first: first, second: second, sign: nil)
    }

    private func z_subtract_any(first:BigInt, second:BigInt, sign:Sign?) -> BigInt {
        var result = second
        result.sign = sign
        return result
    }
    
    func prepare(_ first: BigInt, _ second: BigInt) -> (big:BigInt,small:BigInt,compareResult:Int) {
        if first.compareValue(second) > 0 {
            return (first,second, 1)
        }
        if second.compareValue(first) > 0 {
            return (second, first, -1)
        }
        return (first, first, 0)
    }
    
    func multiply(_ first: BigInt, _ second: BigInt) -> BigInt {
        var accumulated = [Int]()
        var pw = 0
        for n in second.values {
            var intermediate = [Int]()
            var transfer = 0
            for _ in 0..<pw { intermediate.append(0) }
            for m in first.values {
                var p = m * n
                p += transfer
                if p >= 10 {
                    transfer = p / 10
                    p = p % 10
                }
                else {
                    transfer = 0
                }
                intermediate.append(p)
            }
            if ( transfer > 0 ){
                intermediate.append(transfer)
            }
            accumulated = self._sum(first: accumulated, second: intermediate)
            pw += 1
        }
        var res = BigInt()
        res.values = accumulated
        res.sign = multiplySign(first: first.sign, second: second.sign)
        return res
    }
    
    private func multiplySign(first: Sign?, second:Sign?) -> Sign? {
        if first == nil || second == nil {
            return nil
        }
        if let f = first, let s = second {
            return f == s ? Sign.positive : Sign.negative
        }
        return nil
    }

}
