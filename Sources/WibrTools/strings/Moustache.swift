//
//  Moustache.swift
//  WibrTools
//
//  Created by wibr on 26-06-15.
//  Copyright © 2015 Thorquin   . All rights reserved.
//

import Foundation

public struct Moustache {
    var pattern = "\\{\\{[^\\}]*\\}\\}"
    var openLen = 2
    var closeLen = 2
    var leftOffset = 0
    var rightOffset = 0
    
    public init(){
        self.calcOffsets()
    }
    
    public init(pattern:String, openLen:Int, closeLen: Int){
        self.pattern = pattern
        self.openLen = openLen
        self.closeLen = closeLen
        self.calcOffsets()
    }
    
    private mutating func calcOffsets(){
        self.leftOffset = self.openLen
        self.rightOffset = self.openLen + self.closeLen
    }
    
    public func expand(expression : String, values:[String:String]) -> String {
        let nsstr = expression as NSString
        let options : NSRegularExpression.Options = []
        do {
            let re = try  NSRegularExpression(pattern: pattern, options: options)
            let all = NSRange(location: 0, length: nsstr.length)
            var matches : [String] = []
            var pos = 0
            re.enumerateMatches(in: expression, options: [], range: all) { (result, flags, ptr) -> Void in
                guard let result = result else { return }
                let start = result.range.location
                let length = result.range.length
                let pre = nsstr.substring(with: NSRange(location:pos, length:start-pos))
                matches.append(pre)
                let key = nsstr.substring(with: NSRange(location:start + self.leftOffset,length:length - self.rightOffset))
                if let val = values[key] {
                    matches.append(val)
                }
                else {
                    matches.append(key)
                }
                pos = start + length
            }
            if pos < expression.utf8.count {
                matches.append(nsstr.substring(from: pos))
            }
            return matches.reduce("", { $0 + $1 })
        } catch {
            return expression
        }
    }
}
