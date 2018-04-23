//
//  Grid.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 20-04-18.
//

import Foundation

public enum Alignment {
    case Left
    case Center
    case Right
}

public protocol Printer {
    func write(value: String)
    func writeln()
}

public protocol StringEnhancer {
    func beforePadding(value:String, alignment:Alignment) -> String
    func afterPadding(value:String, alignment: Alignment) -> String
}

extension StringEnhancer {
    func beforePadding(value:String, alignment:Alignment) -> String {
        return value
    }
    func afterPadding(value:String, alignment:Alignment) -> String {
        return value
    }
}

public struct ConsolePrinter : Printer {
    public func writeln() {
        print(terminator: "\n")
    }
    
    public func write(value: String) {
        print(value, terminator:"")
    }
}

public struct Column {
    public let width: Int
    public let alignment: Alignment
    
    public var enhancer: StringEnhancer?
    
    public init(width: Int, alignment: Alignment){
        self.width = width
        self.alignment = alignment
    }
    
    public func prepare(value: String) -> String{
        var current = value
        if let eh = self.enhancer {
            current = eh.beforePadding(value: current, alignment: self.alignment)
        }
        let count = current.count
        let remaining = self.width - count
        if remaining < 0 {
            return String(current.prefix(-remaining))
        }
        switch alignment {
            case .Left :
                current = padLeft(current, remaining: remaining)
            case .Center :
                current = padCenter(current, remaining: remaining)
            case .Right:
                current = padRight(current, remaining: remaining)
        }
        if let eh = self.enhancer {
            current = eh.afterPadding(value: current, alignment: self.alignment)
        }
        return current
    }
    
    private func padLeft(_ value: String, remaining: Int) -> String {
        return value + tokens(token: " ", remaining)
    }

    private func padRight(_ value: String, remaining: Int) -> String {
        return tokens(token: " ", remaining) + value
    }

    private func padCenter(_ value: String, remaining: Int) -> String {
        let left = remaining / 2
        let right = self.width - value.count - left
        return tokens(token: " ", left) + value + tokens(token: " ", right)
    }

    private func tokens(token: String, _ count: Int) -> String {
        var s = ""
        for _ in 0..<count {
            s += token
        }
        return s
    }
}

public typealias Row = [String]

public struct Grid {
    public let columns: [Column]
    public var rows = [Row]()
    public var header: Row?
    
    public init(columns: [Column]) {
        self.columns = columns
    }
    
    public mutating func addRow(row:Row) {
        assert(row.count == columns.count)
        self.rows.append(row)
    }
    
    public func write(printer:Printer) {
        if let headerRow = self.header {
            writeRow(printer: printer, row: headerRow)
            printer.writeln()
        }
        for row in rows {
            writeRow(printer: printer, row: row)
            printer.writeln()
        }
    }
    
    private func writeRow(printer: Printer, row:Row){
        for index in 0..<columns.count {
            let col = columns[index]
            let str = row[index]
            let value = col.prepare(value: str)
            printer.write(value: value)
        }
    }
}
