//
//  Regex.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 26-02-17.
//
//

import Foundation

// a simple regular expression type supporting ^ and $ anchors and matching with . and *
public struct Regex {
    fileprivate let regexp: String
    
    public init(_ regexp: String  ){
        self.regexp = regexp
    }
}

public extension Regex {
    func match(_ text:String) -> Bool {
        if regexp.first == "^" {
            return Regex.matchHere(regexp:regexp.dropFirst(), text:text[...])
        }
        var idx = text.startIndex
        while true {
            if Regex.matchHere(regexp: regexp[...], text: text.suffix(from:idx)) {
                return true
            }
            guard idx != text.endIndex else { break }
            text.formIndex(after: &idx)
        }
        return false
    }
}

public extension Regex {
    fileprivate static func matchHere(regexp:Substring, text: Substring) -> Bool {
        if regexp.isEmpty {
            return true
        }
        if let c = regexp.first, regexp.dropFirst().first == "*" {
            return matchStar(character: c, regexp: regexp.dropFirst(2), text: text)
        }
        if regexp.first == "$"  && regexp.dropFirst().isEmpty {
            return text.isEmpty
        }
        if let tc = text.first, let rc = regexp.first, rc == "." || tc == rc {
            return matchHere(regexp: regexp.dropFirst(), text: text.dropFirst())
        }
        return false
    }
    
    fileprivate static func matchStar(character c:Character, regexp:Substring,text:Substring) -> Bool {
        var idx = text.startIndex
        while true {
            if matchHere(regexp: regexp, text: text.suffix(from:idx)) {
                return true
            }
            if idx == text.endIndex || (text[idx] != c && c != "."){
                return false
            }
            text.formIndex(after:&idx)
        }
    }
}

extension Regex : ExpressibleByStringLiteral{
    public init(stringLiteral value: String ){
        regexp = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        self = Regex(stringLiteral: value)
    }
    
    public init(unicodeScalarLiteral value: String){
        self = Regex(stringLiteral: value)
    }
}

