//
//  Logger.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 26-02-17.
//
//

import Foundation

/**
  Usage :
    let logger = Logger("Test")
    logger.log(level:Level, condition:true, message: "this is a test")
 
*/
public enum Level : String {
    case debug
    case info
    case warning
    case error
}

public struct Logger {
    let prefix: String
    
    init(prefix: String){
        self.prefix = prefix
    }
    
    public func log(
        level: Level,
        condition:Bool,
        message: @autoclosure () -> (String),
        file: String = #file,
        line function: String = #function,
        line: Int = #line) {
        if condition { return }
        print("\(level) - \(prefix): \(message()), \(file): \(function) (line\(line))")
    }
    
    public func debug(
        condition:Bool,
        message: @autoclosure () -> (String),
        file: String = #file,
        line function: String = #function,
        line: Int = #line) {
        if condition { return }
        self.log(level: Level.debug, condition: condition, message: message())
    }
    
    public  func info(
        condition:Bool,
        message: @autoclosure () -> (String),
        file: String = #file,
        line function: String = #function,
        line: Int = #line) {
        if condition { return }
        self.log(level: Level.info, condition: condition, message: message())
    }
    
    public  func warning(
        condition:Bool,
        message: @autoclosure () -> (String),
        file: String = #file,
        line function: String = #function,
        line: Int = #line) {
        if condition { return }
        self.log(level: Level.warning, condition: condition, message: message())
    }

    public func error(
        condition:Bool,
        message: @autoclosure () -> (String),
        file: String = #file,
        line function: String = #function,
        line: Int = #line) {
        if condition { return }
        self.log(level: Level.error, condition: condition, message: message())
    }
}
