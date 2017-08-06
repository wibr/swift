//
//  Spirals.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 06-08-17.
//

import Foundation

public struct Spiral {
    
    public struct UlamSequence : Sequence {
        private var offset = 1
        
        public init(offset: Int = 1){
            var a = abs(offset)
            if a == 0 {
                a = 1
            }
            self.offset = a
        }
        
        public func makeIterator() -> UlamIterator {
            return UlamIterator(offset: self.offset)
        }
    }
    
    public struct UlamIterator : IteratorProtocol {
        public typealias NumberPosition = (num:Int, x:Int, y:Int)

        private var number = 1
        private let ulam = Ulam()
        
        public init(offset: Int = 1){
            self.number = offset
        }
        
        public mutating func next() -> NumberPosition? {
            var result: NumberPosition = (self.number, 0, 0)
            let coord = ulam.calculatePosition(num: self.number)
            result.x = coord.x
            result.y = coord.y
            self.number += 1
            return result
        }
    }
    
    public struct Ulam {
        public typealias PositionInRing = (ring:Int, x:Int, y: Int)
        
        public func calcRing(_ num: Int ) -> Int {
            let root = sqrt(Double(num))
            var b = root.rounded(.down)
            if b == root {
                b -= 1
            }
            var c = Int(b)
            if c % 2 == 0 {
                c -= 1
            }
            return c + 2
        }
        
        public static func isCorner(_ position:(Int,Int)) -> Bool {
            return abs(position.0) == abs(position.1)
        }

        public func calculatePosition(num: Int) -> PositionInRing {
            if num == 1 {
                return (0,0,0)
            }
            let ring = calcRing(num)
            let offset = (ring - 2) * (ring - 2)
            let p = num - offset - 1
            let unit = ring - 1
            let section = p / unit
            let remainder = p % unit
            let half = unit / 2
            switch section {
                case 0 : return (ring,  half,                 -half + remainder + 1)
                case 2 : return (ring, -half,                  half - remainder - 1)
                case 1 : return (ring, half - remainder - 1,  half)
                case 3 : return (ring, -half + remainder + 1, -half)
                default :
                    // should not happen
                    return (0,0,0)
            }
        }
    }
}
