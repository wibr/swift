//
//  Matrix.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 04-04-17.
//
//

import Foundation

typealias Cell = (row:Int, column:Int)

enum Direction {
    case north
    case east
    case south
    case west
    
    var value: Int {
        switch self {
          case .north, .west : return -1
          case .east, .south : return 1
        }
    }
}

struct Matrix<T> : Sequence, CustomStringConvertible {
    var grid = [[T?]]()
    
    init(rows:Int, columns:Int){
        for _ in 0..<rows {
            var colArray = [T?]()
            for _ in 0..<columns{
                colArray.append(nil)
            }
            grid.append(colArray)
        }
    }
    
    var rowSize : Int {
        return grid.count
    }
    
    var columnSize : Int {
        if rowSize > 0 {
            return grid[0].count
        }
        return 0
    }
    
    var lastCell: Cell {
        return (row:rowSize-1,column:columnSize-1)
    }
    
    var firstCell: Cell {
        return (0,0)
    }
    
    var numberOfValuesSet : Int {
        return self.filter{self[$0] != nil}.count
    }
    
    public subscript(cell:Cell) -> T? {
        get {
            return self[cell.row, cell.column]
        }
        set(newValue){
            self[cell.row,cell.column] = newValue
        }
        
    }
    public subscript(row:Int, column:Int) -> T? {
        get {
            return grid[row][column]
        }
        set(newValue){
            grid[row][column] = newValue
        }
    }
    
    func gotoCell(cell:Cell, direction:Direction) -> Cell? {
        switch direction {
            case .north : return (cell.row > 0) ? (row: cell.row - 1 , column:cell.column) : nil
            case .south : return (cell.row < rowSize - 1 ) ? (row: cell.row + 1, column:cell.column) : nil
            case .west : return (cell.column > 0 ) ? (row: cell.row, column: cell.column - 1) : nil
            case .east : return (cell.column < columnSize - 1 ) ? (row: cell.row, column: cell.column + 1) : nil
        }
    }
    
    func adjacent(to cell:Cell) -> Matrix {
        let r0 = (cell.row > 0) ? cell.row - 1 : 0
        let r1 = (cell.row < rowSize - 1) ? cell.row + 1 : rowSize - 1
        let c0 = (cell.column > 0) ? cell.column - 1 : 0
        let c1 = (cell.column < columnSize - 1) ? cell.column + 1 : columnSize - 1
        var matrix = Matrix(rows: (r1 - r0) + 1, columns: (c1 - c0) + 1)
        for row in r0 ... r1 {
            for column in c0 ... c1 {
                matrix[row-r0,column-c0] = self[row,column]
            }
        }
        return matrix
    }
    
    public func row(index:Int) -> [T?] {
        return grid[index]
    }
    
    public func column(index:Int) -> [T?] {
        return grid.map{$0[index]}
    }
    
    public var description: String{
        var result = "Matrix (rows: \(rowSize), columns: \(columnSize))\n"
        for row in 0 ..< rowSize {
            for col in 0 ..< columnSize {
                if let val = self[row, col] {
                    result.append("\(val) ")
                }
                else {
                    result.append("?")
                }
            }
            result.append("\n")
        }
        return result
    }
    
    public func makeIterator() -> MatrixIterator {
        return MatrixIterator(matrix:self)
    }
    
    public struct MatrixIterator : IteratorProtocol {
        var current:Cell?
        let matrix: Matrix
        let rowSize:Int
        let columnSize:Int
        
        init(matrix:Matrix){
            self.matrix = matrix
            self.rowSize = self.matrix.rowSize
            self.columnSize = self.matrix.columnSize
            self.current = matrix.firstCell
        }
        
        public mutating func next() -> Cell? {
            guard let cell = self.current else {
                return nil
            }
            var row = cell.row
            var column = cell.column
            if row == (self.rowSize - 1) && column == (self.columnSize - 1) {
                self.current = nil
            }
            else {
                if column == self.columnSize - 1 {
                    column = 0
                    row += 1
                }
                else {
                    column += 1
                }
                self.current = (row:row, column:column)
            }
            return cell
        }
    }
}
