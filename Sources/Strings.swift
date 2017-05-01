//
//  File.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 01-05-17.
//
//

import Foundation

public struct Strings {
    public static func longestRepeatingSequence(value:String) -> String {
        var idx = value.startIndex
        while idx < value.endIndex {
            let s = value[idx]
            print(s)
            idx = value.index(after: idx)
        }
        return ""
    }
}
