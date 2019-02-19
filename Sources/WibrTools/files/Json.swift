//
//  Json.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 23-03-18.
//

import Foundation


public enum CodingError : Error {
    case TemplateNotFound(String)
    case Decode(String)
    case Encode(String)
}

public struct Json {
    public static func encode<T>(object: T) -> Result<Data> where T : Encodable {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(object)
            return Result.success(data)
        }
        catch {
            return Result.failure(error)
        }
    }

    public static func encodeToString<T>(object: T) throws -> String? where T : Encodable  {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(object)
        return String(data:data, encoding:.utf8)
    }

    public static func encodeToStringResult<T>(object: T) -> Result<String> where T : Encodable  {
        do {
            if let json = try encodeToString(object: object){
                return Result.success(json)
            }
            return Result.failure(CodingError.Encode("Unable to encode object: \(object)"))
        }
        catch {
            return Result.failure(error)
        }
    }

    public static func decode<T>(filename:String, type: T.Type) -> Result<T> where T : Decodable {
        guard let data = FileManager.default.contents(atPath: filename) else {
            return Result.failure(CodingError.TemplateNotFound(filename))
        }
        return Json.decode(data, type)
    }
    
    public static func decode<T>(_ data:Data, _ type:T.Type) -> Result<T> where T : Decodable {
        do {
            let decoder = JSONDecoder();
            let obj = try decoder.decode(type, from:data )
            return Result.success(obj)
        }
        catch {
            return Result.failure(error)
        }
    }
}
