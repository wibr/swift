//
//  Logger.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 26-02-17.
//
//

import Foundation

// usage : Logger.log(condition:true, message: "this is a test")
public struct Logger {
    public static func log(condition:Bool, message: @autoclosure () -> (String), file: String = #file, line function: String = #function, line: Int = #line) {
        if condition { return }
        print("Assertion failed: \(message()), \(file): \(function) (line\(line))")
    }
}
