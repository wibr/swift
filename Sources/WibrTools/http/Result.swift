//
//  Result.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 23-03-18.
//

import Foundation

public extension Error {
    func failure<T>() -> Result<T> {
        return Result.failure(self)
    }
}

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public extension Result {
    func map<U>(_ f: (T) -> U) -> Result<U> {
        switch self {
        case .success(let t): return .success(f(t))
        case .failure(let err): return .failure(err)
        }
    }
    func flatMap<U>(_ f: (T) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let t): return f(t)
        case .failure(let err): return .failure(err)
        }
    }
}

public extension Result {
    var isSuccess : Bool {
        switch self {
            case .success: return true
            case .failure: return false
        }
    }
    
    var isError : Bool {
        return !isSuccess
    }
}

public extension Result where T : Encodable {
    func json() -> Result<String> {
        switch self {
        case .success(let t) :
            return Json.encodeToStringResult(object: t)
        case .failure(let e) :
            return .failure(e)
        }
    }
}

public extension Result {
    // Return the value if it's a .Success or throw the error if it's a .Failure
    func resolve() throws -> T {
        switch self {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
    
    func value() -> T? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }
    
    func error() -> Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
        
    }
    
    // Construct a .Success if the expression returns a value or a .Failure if it throws
    init(_ throwingExpr: () throws -> T) {
        do {
            let value = try throwingExpr()
            self = Result.success(value)
        } catch {
            self = Result.failure(error)
        }
    }
}

public extension Result {
    func decodeError<T>() -> T? {
        if let err = error(), err is T {
           return err as? T
        }
        return nil
    }
}

extension Result : CustomStringConvertible {
    public var description: String {
        switch self {
        case .success(let value): return "\(value)"
        case .failure(let error): return "\(error)"
        }
    }
}

