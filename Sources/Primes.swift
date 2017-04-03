//
//  Primes.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 03-04-17.
//
//

import Foundation


public struct Primes : Sequence {
    public init() {
        
    }
    public func makeIterator() -> PrimesIterator {
        return PrimesIterator()
    }
}

public struct PrimesIterator : IteratorProtocol {
    private var found = [Int]()
    private var state = 2
    
    public init() {
        self.found.append(2)
    }
    
    public mutating func next() -> Int? {
        let returnValue = self.state
        var next = returnValue
        if next == 2 {
            next = 3
        }
        else {
            next += 2
            while self.found.contains(where: {next % $0 == 0}) {
                next += 2
            }
        }
        self.found.append(next)
        self.state = next
        return returnValue
    }
}
