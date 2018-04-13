//
//  Math.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 16-04-17.
//
//

import Foundation

prefix operator √

public prefix func √ (number:Double) -> Double {
    return sqrt(number)
}

public enum MathConstant : Double {
    case τ = 6.283185307179586476925286766559005768394338798750211641949889184615632812572417997256069650684234135
    case e = 2.71828182845904523536028747135266249
    case φ = 1.61803398874989484820458683436563811 // ½(1+√5)
    case Sqrt2 = 1.41421356237309504880168872420969807
    case Sqrt3 = 1.732050807568877293527446341505
}

public struct FibonaciSequence : Sequence {
    public func makeIterator() -> FibonaciIterator {
        return FibonaciIterator()
    }
}

public struct FibonaciIterator : IteratorProtocol {
    var state = (1,1)
    
    public mutating func next() -> Int? {
        let upcoming = state.0
        state = (state.1, state.0 + state.1)
        return upcoming
    }
}

public final class ReadRandom {
    let handle = FileHandle(forReadingAtPath: "/dev/urandom")!
    deinit {
        handle.closeFile()
    }
    
    public func getByte() -> UInt8 {
        let byte = handle.readData(ofLength: 1)
        return byte[0]
    }
    
}

extension ReadRandom : IteratorProtocol {
    public func next() -> UInt8? {
        return getByte()
    }
}

extension ReadRandom : Sequence {
}

public struct Math {
    
    public static func possibleSqrt(num:Int) -> (Int,Int) {
        var y = num / 2
        if y == 0 {
            return (1,0)
        }
        var x = num / y
        while y > x {
            y = (x + y) / 2
            x = num / y
        }
        return (y, num - y * y)
    }
    
    public static func power(base:Int, exponent:Int) -> Double {
        return pow(Double(base),Double(exponent))
    }
    //*
    // max value: 170
    //*
    public static func factorial(_ n:Int) -> Double {
        precondition(n < 170,"maximum number is 170")
        if ( n == 0 ){
            return 1.0
        }
        var p = Double(n)
        var f = p
        while ( p > 1 ){
            p -= 1
            f *= p
        }
        return f
    }
    
    /**
     * Least Common Multiple
     */
    public static func lcm(_ x:Int, _ y: Int) -> Int {
        return (x * y) / Math.gcd(x,y)
    }
    
    /**
     * GCD (greatest common divisor)
     * Input: two integers (x,y)
     * Output: greatest common divisor of x & y
     */
    public static func gcd(_ x:Int, _ y:Int) -> Int {
        var f = Swift.max(x,y)
        var s = Swift.min(x,y)
        while s != 0 {
            let z = f % s
            f = s
            s = z
        }
        return f
    }
    
    /**
     Extended Euclidian Algorithem
     */
    public static func eea(_ a: Int, _ b:Int) -> (d:Int, m:Int, n:Int) {
        var w = (a:a, b:b)
        var p = (s:1, t:0, u:0, v:1)
        while w.b != 0 {
            let x = (q: w.a / w.b, r: w.a % w.b)
            let tmp = (unew: p.s, vnew: p.t)
            p.s = p.u - (x.q * p.s)
            p.t = p.v - (x.q * p.t)
            w.a = w.b
            w.b = x.r
            p.u = tmp.unew
            p.v = tmp.vnew
        }
        return (w.a, p.u, p.v)
    }

    public static func random(from: Int, to: Int) -> Int {
        let range = to - from + 1
        return Int(arc4random_uniform(UInt32(range)))
    }

    public static func discriminant(a:Double, b:Double, c:Double) -> Double {
        return (b*b) - (4*a*c)
    }
    
    public static func abcFormula(a:Double, b:Double, c:Double) -> (Double,Double)? {
        let d = Math.discriminant(a: a, b: b, c: c)
        let aa = 2 * a
        if d < 0 { return nil }
        if d == 0 {
            let r = -b / aa
            return (r,r)
        }
        let sqd = sqrt(d)
        let r1 = (-b + sqd) / aa
        let r2 = (-b - sqd) / aa
        return (r1, r2)
    }
    
    public static func karatsuba(num1:Int, num2:Int) -> Int{
        if (num1 < 10) || (num2 < 10){
            return num1 * num2
        }
    /* calculates the size of the numbers */
        let m = max(Math.size(n:num1), Math.size(n:num2))
        let m2 = m/2
    /* split the digit sequences about the middle */
        let a1 = Math.split(n:num1, at:m2)
        let a2 = Math.split(n:num2, at:m2)
    /* 3 calls made to numbers approximately half the size */
        let z0 = Math.karatsuba(num1:a1.low, num2:a2.low)
        let z1 = Math.karatsuba(num1:(a1.low + a1.high), num2:(a2.low + a2.high))
        let z2 = Math.karatsuba(num1:a1.high, num2:a2.high)
        return (z2 * 10^(2 * m2) ) + ( (z1 - z2 - z0) * 10^(m2) ) + (z0)
    }
    
    private static func split(n: Int, at position: Int) -> (high:Int, low:Int){
        let divisor = Int(pow(10,Double(position)))
        let high = n / divisor
        let low = n % divisor
        return (high:high*divisor, low:low)
    }
    public static func getDigits(number:Int) -> [Int] {
        return toBase(number: number, base: 10)
    }
    /**
     Converts a 10-base number to a value represended in the given base
     */
    
    public static func toBinary(number:Int) -> [Int]{
        return Math.toBase(number: number, base: 2)
    }
    
    public static func bitLength(number: Int) -> Int {
        var p = number
        var count = 0
        while p > 0 {
            p /= 2
            count += 1
        }
        return count
    }
    
    public static func toBase(number:Int, base:Int = 2) -> [Int] {
        var values = [Int]()
        var v = number
        repeat {
            values.insert(v % base, at: 0)
            v = v / base
        } while v > 0
        return values
    }
    
    public static func fromBinary(number:[Int]) -> Int {
        return Math.fromBase(number: number, base: 2)
    }
    
    public static func fromBase(number:[Int], base:Int) -> Int {
        var s = 0
        var p = 1
        for index in stride(from: number.count, to: 0, by: -1){
            s += (p * number[index-1])
            p *= base
        }
        return s
    }

    public static func size(n:Int, base:Int = 10) -> Int {
        var p = 0
        var k = n
        while( k > 0){
            k = k / base
            p += 1
        }
        return p
    }
    
    public static func factorize(n:Int) -> [Int] {
        var factors = [Int]()
        if n == 1 {
            return factors
        }
        let end = Int(sqrt(Double(n)).rounded(.up))
        var current = n
        var index = 0
        var p = Primes.First[index]
        let k = Primes.First.count
        while current > 1 && p <= end {
            current = testFactor(num:current, divisor:p, factors:&factors)
            if index < k {
                p = Primes.First[index]
                index += 1
            }
            else {
                p += 2
            }
        }
        if current > 1 {
            factors.append(current)
        }
        return factors
    }
    
    private static func testFactor(num:Int, divisor:Int, factors: inout [Int]) -> Int {
        var current = num
        while current % divisor == 0 {
            factors.append(divisor)
            current = current / divisor
        }
        return current
    }
}


