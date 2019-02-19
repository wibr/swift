//
//  Nodes.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 17-10-17.
//

import Foundation

public class Node<T : Equatable> {
    public var value: T
    public var edges = [Edge<T>]()
    
    public init(value:T){
        self.value = value
    }
    
    public func attach(node:Node<T>, weight:Double = 1.0) -> Node<T> {
        let edge = Edge<T>(weight: weight, left: self, right: node)
        self.edges.append(edge)
        return node
    }
    
    public func detach(node:Node<T>) {
        
    }
    
    public func getEdge(node:Node<T>) -> Edge<T>? {
        return self.edges.filter{$0.right == node}.first
    }
}

extension Node : Equatable{
    public static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.value == rhs.value
    }
}

public class Edge<S : Equatable> {
    public var weight: Double
    public var left: Node<S>
    public var right: Node<S>
    
    public init(weight:Double, left: Node<S>, right: Node<S>){
        self.weight = weight
        self.left = left
        self.right = right
    }
    
    public convenience init(left: Node<S>, right: Node<S>){
        self.init(weight:1.0, left: left, right: right)
    }
}


struct NodeDemo {
    func execute() {
        let first = Node(value: "first")
        let second = Node(value: "second")
        _ = first.attach(node: second)
        _ = first.getEdge(node: second)
        
        
        
    }
}
