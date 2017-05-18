//
//  File.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 01-05-17.
//
//

import Foundation


public struct Strings {
    public static let AlphaNumerics = [
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
        "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
        "0","1","2","3","4","5","6","7","8","9"]

    public static func longestRepeatingSequence(value:String) -> String {
        var idx = value.startIndex
        while idx < value.endIndex {
            let s = value[idx]
            print(s)
            idx = value.index(after: idx)
        }
        return ""
    }
    
    
    public static func randomString(length: Int) -> String {
        let len = UInt32(Strings.AlphaNumerics.count)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            randomString += Strings.AlphaNumerics[Int(rand)]
        }
        return randomString
    }
}
