//
//  Arrays.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 20-08-17.
//

import Foundation

struct Arrays {

    public static func trimLeadingTokens<T : Equatable>(array:[T], value:T) -> [T] {
        var i = 0
        while array[i] == value {
            i += 1
        }
        if i > 0 {
            return [T](array.suffix(from: i))
        }
        return array
    }
    
    public static func trimTrailingTokens<T : Equatable>(array:[T], value:T) -> [T] {
        var i = array.count - 1
        while array[i] == value {
            i -= 1
        }
        if i > 0 {
            return [T](array.prefix(upTo: i))
        }
        return array
    }

    public static  func isPalindrome<T : Equatable>(value:[T]) -> Bool {
        let n = value.count
        let half = n / 2
        for p in 0..<half {
            if value[p] != value[n-p-1] {
                return false
            }
        }
        return true
    }
}
