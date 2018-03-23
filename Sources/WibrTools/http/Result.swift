//
//  Result.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 23-03-18.
//

import Foundation

extension Error {
    func failure<T>() -> Result<T> {
        return Result.failure(self)
    }
}

public enum Result<T> {
    case success(T)
    case failure(Error)
}

extension Result {
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

extension Result where T : Encodable {
    func json() -> Result<String> {
        switch self {
        case .success(let t) :
            return Json.encodeToResult(object: t)
        case .failure(let e) :
            return .failure(e)
        }
    }
}

extension Result {
    // Return the value if it's a .Success or throw the error if it's a .Failure
    func resolve() throws -> T {
        switch self {
        case Result.success(let value): return value
        case Result.failure(let error): throw error
        }
    }
    
    func value() -> T? {
        switch self {
        case Result.success(let value): return value
        case Result.failure: return nil
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

extension Result : CustomStringConvertible {
    public var description: String {
        switch self {
        case Result.success(let value): return "\(value)"
        case Result.failure(let error): return "\(error)"
        }
    }
}

