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

public enum RowType {
    case Header
    case Row
    case Footer
}

public protocol Printer {
    func write(value: String, rowType: RowType, rowIndex: Int)
    func writeLine(width: Int, token: String)
    func writeln()
}

public protocol StringEnhancer {
    func beforePadding(value:String,  column: Column) -> String
    func afterPadding(value:String,  column: Column) -> String
}

extension StringEnhancer {
    func beforePadding(value:String, column: Column) -> String {
        return value
    }
    func afterPadding(value:String,  column: Column) -> String {
        return value
    }
}
public protocol LineRenderer {
    func renderLine(width:Int, token:String) -> String
    func renderRow(value: String, rowType: RowType, rowIndex: Int) -> String
}


public struct ConsolePrinter : Printer {
    public var lineRenderer : LineRenderer?
    
    public init() {
    }
    
    public func writeln() {
        print(terminator: "\n")
    }
    
    public func write(value: String, rowType: RowType, rowIndex: Int) {
        var line: String?
        if let lr = self.lineRenderer {
            line = lr.renderRow(value: value, rowType: rowType, rowIndex: rowIndex)
        }
        else {
            line = value
        }
        print(line!, terminator: "")
    }
    
    public func writeLine(width: Int, token: String) {
        var line: String?
        if let lr = self.lineRenderer {
            line = lr.renderLine(width: width, token: token)
        }
        else {
            line = Strings.generateString(token: token, width)
        }
        print(line!, terminator: "")
    }
    
}

public struct Column {
    public let label: String
    public let width: Int
    public var alignment: Alignment?
    public var enhancer: StringEnhancer?
    
    public init(label: String, width: Int, alignment: Alignment){
        self.label = label
        self.width = width
        self.alignment = alignment
    }
    
    public init(label:String,width: Int){
        self.label = label
        self.width = width
    }
    
    public func prepare(value: String) -> String{
        var current = value
        if let eh = self.enhancer {
            current = eh.beforePadding(value: current,  column: self)
        }
        let count = current.count
        let remaining = self.width - count
        if remaining < 0 {
            return String(current.prefix(-remaining))
        }
        if let al = self.alignment {
            switch al {
                case .Left :
                    current = padLeft(current, remaining: remaining)
                case .Center :
                    current = padCenter(current, remaining: remaining)
                case .Right:
                    current = padRight(current, remaining: remaining)
            }
        }
        if let eh = self.enhancer {
            current = eh.afterPadding(value: current, column: self)
        }
        return current
    }
    
    private func padLeft(_ value: String, remaining: Int) -> String {
        return value + Strings.generateString(token: " ", remaining)
    }

    private func padRight(_ value: String, remaining: Int) -> String {
        return Strings.generateString(token: " ", remaining) + value
    }

    private func padCenter(_ value: String, remaining: Int) -> String {
        let left = remaining / 2
        let right = self.width - value.count - left
        return Strings.generateString(token: " ", left) + value + Strings.generateString(token: " ", right)
    }

}

public typealias Row = [String]

public struct Grid {
    public static let EM_DASH = "—"
    public let columns: [Column]
    public var rows = [Row]()
    public var header: Row?
    public var footer: Row?
    public var headerSeparatorToken: String?
    public var footerSeparatorToken: String?
    
    public init(columns: [Column]) {
        self.columns = columns
    }
    
    public mutating func addRow(row:Row) {
        assert(row.count == columns.count)
        self.rows.append(row)
    }
    
    public mutating func clearRows() {
        self.rows.removeAll()
    }
    
    public func write(printer:Printer) {
        var index = 0
        if let headerRow = self.header {
            writeRow(printer: printer, row: headerRow, rowType: .Header, rowIndex: index)
            printer.writeln()
            index += 1
        }
        if let hst = self.headerSeparatorToken {
            let gridWidth = self.columns.reduce(0) {$0 + $1.width}
            printer.writeLine(width:gridWidth, token: hst)
            printer.writeln()
        }
        for row in rows.enumerated() {
            index += row.offset
            writeRow(printer: printer, row: row.element, rowType: .Row, rowIndex: index)
            printer.writeln()
        }
        if let fst = self.footerSeparatorToken {
            let gridWidth = self.columns.reduce(0) {$0 + $1.width}
            printer.writeLine(width:gridWidth, token: fst)
            printer.writeln()
        }
        if let footerRow = self.footer {
            writeRow(printer: printer, row: footerRow, rowType: .Footer, rowIndex: index)
            printer.writeln()
        }
    }
    
    private func writeRow(printer: Printer, row:Row, rowType: RowType, rowIndex: Int){
        for index in 0..<columns.count {
            let col = columns[index]
            let str = row[index]
            let value = col.prepare(value: str)
            printer.write(value: value, rowType: rowType, rowIndex: rowIndex)
        }
    }
}
