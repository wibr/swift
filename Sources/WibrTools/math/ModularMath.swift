//
//  ModularMath.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 31-08-17.
//

import Foundation

public struct Mod {
    let modulo: Int
    
    
    
    public func add(_ a:Int, _ b: Int ) -> Int {
        return ModularMath.add(a, b, modulo: self.modulo)
    }
    
    public func subtract(_ a: Int, _ b: Int) -> Int {
        return ModularMath.subtract(a, b, modulo: self.modulo)
    }
    
    public func multiply(_ a: Int, _ b: Int) -> Int {
        return ModularMath.multiply(a, b, modulo: self.modulo)
    }
    
    public func exponentiate( _ a: Int, b:Int ) -> Int {
        return ModularMath.exponentiate(a, b, modulo: self.modulo)
    }
    
    public func inverse( _ a : Int ) -> Int {
        return ModularMath.inverse(a, modulo: self.modulo)
    }
    
    public func divide(divider a:Int, divisor b:Int ) -> Int {
        return ModularMath.divide(divider: a, divisor: b,  modulo: self.modulo)
    }
}

public struct ModularMath {
    
    public static func add(_ a:Int, _ b:Int, modulo p: Int) -> Int {
        let r = (a % p) + (b % p)
        return r >= p ? r - p : r
    }
    
    public static func subtract(_ a:Int, _ b:Int, modulo p: Int) -> Int {
        let r = (a % p) - (b % p)
        return r < 0 ? r + p : r
    }

    public static func multiply(_ a:Int, _ b:Int, modulo p: Int) -> Int {
        var n = a
        var r = 0
        for bit in 0 ..< Math.bitLength(number: b){
            if (b & (1 << bit)) > 0 {
                r = (r + n) % p
            }
            n = (n + n) % p
        }
        return r
    }
    
    public static func exponentiate(_ a:Int, _ b:Int, modulo p:Int ) -> Int {
        var n = a
        var r = 1
        for bit in 0 ..< Math.bitLength(number:b) {
            if (b & (1 << bit)) > 0 {
                r = ModularMath.multiply(r, n, modulo:p)
            }
            n = ModularMath.multiply(n, n, modulo: p)
        }
        return r
    }
    
    public static func inverse(_ a:Int, modulo p: Int )-> Int {
        let r = Math.eea(p, a)
        return r.m < 0 ? p + r.m : r.m
    }
    
    public static func divide(divider a:Int, divisor b:Int, modulo p:Int) -> Int {
        let inverse = ModularMath.inverse(b, modulo: p)
        return ModularMath.multiply(a, inverse, modulo: p)
    }
}
