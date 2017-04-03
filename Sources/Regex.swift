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

extension Regex {
    public func match(_ text:String) -> Bool {
        if regexp.characters.first == "^" {
            return Regex.matchHere(regexp:regexp.characters.dropFirst(), text:text.characters)
        }
        return false
    }
}

extension Regex {
    fileprivate static func matchHere(regexp:String.CharacterView, text: String.CharacterView) -> Bool {
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
    
    fileprivate static func matchStar(character c:Character, regexp:String.CharacterView,text:String.CharacterView) -> Bool {
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

