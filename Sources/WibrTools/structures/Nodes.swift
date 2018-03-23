//
//  Nodes.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 17-10-17.
//

import Foundation

class Node<T : Equatable> {
    var value: T
    var edges = [Edge<T>]()
    
    init(value:T){
        self.value = value
    }
    
    func attach(node:Node<T>, weight:Double = 1.0) -> Node<T> {
        let edge = Edge<T>(weight: weight, left: self, right: node)
        self.edges.append(edge)
        return node
    }
    
    func detach(node:Node<T>) {
        
    }
    
    func getEdge(node:Node<T>) -> Edge<T>? {
        return self.edges.filter{$0.right == node}.first
    }
}

extension Node : Equatable{
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.value == rhs.value
    }
}

class Edge<S : Equatable> {
    var weight: Double
    var left: Node<S>
    var right: Node<S>
    
    init(weight:Double, left: Node<S>, right: Node<S>){
        self.weight = weight
        self.left = left
        self.right = right
    }
    
    convenience init(left: Node<S>, right: Node<S>){
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
