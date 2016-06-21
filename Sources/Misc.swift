import Foundation

public func power(base:Int, exponent:Int) -> Double {
	return pow(Double(base),Double(exponent))
}
//* 
// max value: 170 
//*
public func factorial(_ n:Int) -> Double {
	if ( n == 0 ){
		return 1.0
	}
	var p = Double(n)
	var f = p
	while ( p > 1 ){
		p -= 1
		f *= p
	}
	return f
}

public func swap<T>(_ row: inout [T], _ first: Int, _ second: Int){
	let temp = row[first]
	row[first] = row[second]
	row[second] = temp
}


public enum InitialisationError : ErrorProtocol {
	case InvalidArgument(String)
	case MissingArgument(String)
}
