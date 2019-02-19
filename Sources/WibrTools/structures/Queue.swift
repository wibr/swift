//
//  Queue.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 03/02/2019.
//

import Foundation

public protocol Queue
{
    associatedtype Element
    
    // Enqueue the element to self
    mutating func enqueue(_ newElement: Element)
    
    // Dequeue an element from self
    mutating func dequeue() -> Element?
}

public struct FIFOQueue<Element> : Queue {
    private var left: [Element] = []
    private var right: [Element] = []
    
    public init(){
        
    }
    
    public mutating func enqueue(_ newElement: Element) {
        right.append(newElement)
    }
    
    public mutating func dequeue() -> Element? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}

extension FIFOQueue : MutableCollection {
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return left.count + right.count
    }
    
    public func index(after i: Int) -> Int {
        precondition( i < endIndex )
        return i + 1
    }
    
    public subscript(position: Int) -> Element {
        get {
            precondition( (0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                return left[left.count-position - 1]
            }
            return right[position - left.count]
        }
        set {
            precondition( (0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                left[left.count - position - 1 ] = newValue
            }
            else {
                right[position - left.count] = newValue
            }
        }
    }
}

extension FIFOQueue : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        left = elements.reversed()
        right = []
    }
}

extension FIFOQueue : RangeReplaceableCollection {
    public mutating func replaceSubrange<C:Collection>(_ subrange:Range<Int>, with newElements:C) where C.Element == Element {
        right = left.reversed() + right
        left.removeAll()
        right.replaceSubrange(subrange, with: newElements)
    }
}

