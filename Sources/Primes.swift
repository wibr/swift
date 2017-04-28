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
    
    public func isPrime(inputNum:Int) -> Bool{
        // check if input num is divisible by 2
        if inputNum % 2 == 0 {
            // if 2 return true (prime) otherwise return false
            return inputNum == 2
        }
        let upperBound = Int(sqrt(Double(inputNum)))
        // loop until test <= square root of inputNum
        for test in stride(from:3, to:upperBound, by:2){
            if inputNum % test == 0{
                return false;
            }
        }
        return true;
    }
    
    /**
     * Fast Modular Exponentiation
     * Input: factor, power, modulus
     * Output: factor^power % modulus
     */
    public func fasterMod(factor:Int,power:Int,modulus:Int) -> Int {
        var result = 1
        var p = power
        var f = factor
        while p > 0 {
            if p % 2 == 1 {
                result = (result * f) % modulus
                p = p - 1
            }
            p = p / 2
            f = (f * f) % modulus
        }
        return result
    }
    
    public func probablyPrime(_ num:Int, _ numTrials:Int = 20) -> Bool{
        for _ in 0 ..< numTrials {
            let randTest = Math.random(from: 1, to: num - 1)
            if Math.gcd(randTest, num) != 1 {
                return false
            }
            let fm = fasterMod(factor:randTest, power: num - 1, modulus: num)
            if (fm != 1){
                return false
            }
        }
        return true
    }
    
    
    public static let First_100 = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509,521,523,541,547,557]
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


