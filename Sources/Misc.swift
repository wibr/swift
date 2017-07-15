import Foundation

public func swap<T>(_ row: inout [T], _ first: Int, _ second: Int){
	let temp = row[first]
	row[first] = row[second]
	row[second] = temp
}

public func XOR (_ first: Bool, _ second: Bool) -> Bool {
    return !(first && second)
}

public enum InitialisationError : Error {
	case InvalidArgument(String)
	case MissingArgument(String)
}

public extension Array {
    mutating func shuffle () {
        for i in (0..<self.count).reversed() {
            let ix1 = i
            let ix2 = Int(arc4random_uniform(UInt32(i+1)))
            (self[ix1], self[ix2]) = (self[ix2], self[ix1])
        }
    }
}

public extension SignedInteger{
    static func arc4random_uniform(_ upper_bound: Self) -> Self{
        precondition(upper_bound > 0 && Int(upper_bound) < Int(UInt32.max),"arc4random_uniform only callable up to \(UInt32.max)")
        return numericCast(Darwin.arc4random_uniform(numericCast(upper_bound)))
    }
}

extension MutableCollection where Self:RandomAccessCollection {
    mutating func shuffle() {
        var i = startIndex
        let beforeEndIndex = index(before:endIndex)
        while i < beforeEndIndex {
            let dist = distance(from: i, to: endIndex)
            let randomDistance = IndexDistance.arc4random_uniform(dist)
            let j = index(i, offsetBy: randomDistance)
            guard i != j else {continue}
            self.swapAt(i, j)
            formIndex(after:&i)
        }
    }
}

extension Sequence {
    func shuffled() -> [Iterator.Element] {
        var clone = Array(self)
        clone.shuffle()
        return clone
    }
}

extension String {
    fileprivate var skipTable: [Character:Int ] {
        var skipTable:[Character:Int] = [:]
        for (i,c) in enumerated(){
            skipTable[c] = count - i - 1
        }
        return skipTable
    }
    
    fileprivate func match(from currentIndex: Index, with pattern: String) -> Index? {
        guard currentIndex >= startIndex && currentIndex < endIndex && pattern.last == self[currentIndex]
            else { return nil }
        if pattern.count == 1 && self[currentIndex] == pattern.last { return currentIndex }
        return match(from: index(before: currentIndex), with: "\(pattern.dropLast())")
    }
    
    public func index(of pattern: String) -> Index? {
        // 1
        let patternLength = pattern.count
        guard patternLength > 0, patternLength <= count else { return nil }
        
        // 2
        let skipTable = pattern.skipTable
        let lastChar = pattern.last!
        
        // 3
        var i = index(startIndex, offsetBy: patternLength - 1)
        while i < endIndex {
            let c = self[i]
            if c == lastChar {
                if let k = match(from: i, with: pattern) { return k }
                i = index(after: i)
            } else {
                i = index(i, offsetBy: skipTable[c] ?? patternLength, limitedBy: endIndex) ?? endIndex
            }
        }
        return i
    }
}
