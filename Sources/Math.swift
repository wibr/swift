//
//  Math.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 16-04-17.
//
//

import Foundation

public struct Math {
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
}
