
public struct ComplexNumber{
    static let Zero = ComplexNumber()
    
	let real: Double
	let imaginary: Double

	init(real:Double = 0.0, imaginary:Double = 0.0){
		self.real = real
		self.imaginary = imaginary
	}
    
    
    func add(number complexNumber: ComplexNumber) -> ComplexNumber {
        let r = self.real + complexNumber.real
        let i = self.imaginary + complexNumber.imaginary
        return ComplexNumber(real:r, imaginary:i)
    }
    
    // (a + bi) * (c + di) = ac - bd + (ad + bc)i
    func multiply(with complexNumber: ComplexNumber) -> ComplexNumber {
        let a = self.real; let b = self.imaginary; let c = complexNumber.real; let d = complexNumber.imaginary
        let nr = (a*c) - (b*d)
        let ni = (a*d) + (b*c)
        return ComplexNumber(real: nr, imaginary: ni)
    }
    
    func divide(by complexNumber: ComplexNumber) -> ComplexNumber? {
        let a = self.real; let b = self.imaginary; let c = complexNumber.real; let d = complexNumber.imaginary
        guard c != 0 && d != 0 else {
            return nil
        }
        let denominator = (c*c + d*d)
        let nr = (a*c + b*d) / denominator
        let ni = (b*c - a*d) / denominator
        return ComplexNumber(real: nr, imaginary: ni)
    }
    
    func power(exponent:UInt8) -> ComplexNumber {
        guard exponent == 0 else { return ComplexNumber(real:1.0)}
        guard exponent == 1 else { return self }
        var res = self
        for _ in [1..<exponent]{
            res = res * self
        }
        return res
    }
    
    func conjugate() -> ComplexNumber {
        return ComplexNumber(real:self.real, imaginary:-self.imaginary)
    }
    
    func negate() -> ComplexNumber {
        return ComplexNumber(real: -self.real, imaginary: -self.imaginary)
    }
}

extension ComplexNumber : Equatable {
    
    public static func == (lhs:ComplexNumber, rhs:ComplexNumber ) -> Bool {
        return lhs.real == rhs.real && lhs.imaginary == rhs.imaginary
    }
    
    public static func + (lhs:ComplexNumber, rhs:ComplexNumber) -> ComplexNumber {
        return lhs.add(number: rhs)
    }
    
    public static prefix func - (number:ComplexNumber) -> ComplexNumber {
        return ComplexNumber(real: -number.real, imaginary: -number.imaginary)
    }
    
    public static func - (lhs:ComplexNumber, rhs:ComplexNumber) -> ComplexNumber {
        return lhs + -rhs
    }
    
    public static func * (lhs:ComplexNumber, rhs:ComplexNumber) -> ComplexNumber {
        return lhs.multiply(with: rhs)
    }
    
    public static func / (lhs:ComplexNumber, rhs: ComplexNumber) -> ComplexNumber? {
        return lhs.divide(by: rhs)
    }
    
    public static func ^ (number:ComplexNumber, exponent: UInt8) -> ComplexNumber {
        return number.power(exponent: exponent)
    }

    public static prefix func ! (number:ComplexNumber) -> ComplexNumber {
        return number.conjugate()
    }

}

extension ComplexNumber : CustomStringConvertible {
    public var description: String {
        if self == ComplexNumber.Zero {
            return "()"
        }
        if real == 0.0 {
            return "(\(self.imaginary)i)"
        }
        if imaginary == 0.0 {
            return "(\(self.real))"
        }
        var token = "+"
        var ival = self.imaginary
        if  self.imaginary < 0.0 {
            token = "-"
            ival = -self.imaginary
        }
        return "(\(self.real) \(token) \(ival)i)"
    }
}
