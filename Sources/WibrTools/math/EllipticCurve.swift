//
//  EllipticCurve.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 30-09-17.
//

import Foundation

/**
 https://www.johannes-bauer.com/compsci/ecc
 */
public struct Def {
    public static let Constant = 4.0
    public static let XFactor = 2.0
}

public struct Point {
    public static let Zero = Point(x:0,y:0)
    
    let x:Double
    let y:Double
    
    public func add(point:Point) -> Point {
        let dy = self.y - point.y
        let dx = self.x - point.x
        let s = dy / dx
        let rx = (s * s)  - dx
        let ry = s * (self.x - rx) - self.y
        return Point(x: rx, y: ry)
    }
    
    public func double() -> Point {
        let s = ((3 + self.x * self.x) + Def.XFactor) / (2 * self.y)
        let rx = s * s  - (2 * self.x)
        let ry = s * (self.x - rx) - self.y
        return Point(x: rx, y: ry)
    }
    
    public func multiply(scalar:Int) -> Point {
        var n = self
        var r = Point.Zero
        let len = Math.bitLength(number: scalar)
        for bit in 0..<len {
            if ( (scalar & (1 << bit)) > 0 ) {
                r = r.add(point: n)
            }
            n = n.double()
        }
        return r
    }
}

public struct EllipticCurve {
    
    let ellipse: (Double) -> Double
    
    public init?() {
        
        let check = 4 * Def.XFactor * Def.XFactor * Def.XFactor - 27 * Def.Constant * Def.Constant
        guard check != 0 else {
            return nil
        }
        self.ellipse = { (x:Double) in
            return (x * x * x) + (Def.XFactor * x) + Def.Constant
        }
    }
    
}

