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

extension FIFOQueue : Collection {
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
        precondition( (0..<endIndex).contains(position), "Index out of bounds")
        if position < left.endIndex {
            return left[left.count-position - 1]
        }
        return right[position - left.count]
    }
}

extension FIFOQueue : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        left = elements.reversed()
        right = []
    }
}
