import Foundation

public enum SimpleType {
    case STRING(String)
    case BOOL(Bool)
    case NUMBER(Int)
    case NULL
    
    public var string : String? {
        if case .STRING(let s) = self {
            return s
        }
        return nil
    }
    
    public var bool : Bool? {
        if case .BOOL(let b) = self {
            return b
        }
        return nil
    }
    
    public var number : Int? {
        if case .NUMBER(let n) = self {
            return n
        }
        return nil
    }
    
    public func value() -> String {
        switch (self) {
            case let .STRING(v) : return v
            case let .BOOL(b) : return "\(b)"
            case let .NUMBER(i) : return "\(i)"
            case .NULL : return ""
        }
    }
    
    public func name() -> String {
        switch self {
            case .STRING : return "STRING"
            case .NUMBER : return "NUMBER"
            case .BOOL : return "BOOL"
            case .NULL : return "NULL"
        }
    }
    
    
    public static func fromType(type:SimpleType, value:String) -> SimpleType {
        switch type {
        case .STRING : return .STRING(value)
        case .NUMBER :
            if let num = Int(value) {
                return .NUMBER(num)
            }
            return .NULL
        case .BOOL :
            let b = (value == "true") ? true : false
            return .BOOL(b)
        case .NULL : 
            return type
        }
    }
    
    public static func fromString(value:String) -> SimpleType {
        if ( value == "true" ){
            return .BOOL(true)
        }
        if ( value == "false" ){
            return .BOOL(false)
        }
        if let num = Int(value){
            return .NUMBER(num)
        }
        return .STRING(value)
    }
}

public protocol AppConfig {
    var description: String {get}
    var options: [String] {get}
    func getTypeInfo(option:String) -> SimpleType?
}

public extension AppConfig {
    public var optionDesc: String {
        var result = ""
        let count = options.count
        if ( count > 0 ){
            for (index, option) in options.enumerated() {
                if let ti = getTypeInfo(option: option) {
                    result += "-\(option) : \(ti.value()) [\(ti.name())]"
                    if (index < count - 1) {
                        result += ", "
                    }
                }
            }
        }
        else {
            result += " <No information>"
        }
        return result
    }
}

public struct CLI {
    var config:AppConfig?
    
    public init(){
        
    }
    
    public init(config:AppConfig?){
        self.config = config
    }
    
    public var appName: String {
        return CommandLine.arguments[0]
    }
    
    public func usage() {
        if let cfg = self.config {
            var opts = ""
            if (cfg.options.count > 0){
                opts = " [options]"
            }
            print("Usage: \(self.appName)\(opts)")
            print("  Options: \(cfg.optionDesc)")
            print("\(cfg.description)")
        }
        else {
            print("Usage: \(self.appName)")
        }
    }
    
    public func info(args:[String:SimpleType], full:Bool = false) {
        if let cfg = self.config {
            for (key,value) in args {
                if let ti = cfg.getTypeInfo(option: key) {
                    var message = "\(ti.value()): \(value.value())"
                    if ( full ) {
                        message +=  " [\(ti.name())]"
                    }
                    print(message)
                }
            }
        }
        else {
            for (key,value) in args {
                print("\(key) : \(value)")
            }
        }
    }
    
    public func processArgs() -> [String:SimpleType] {
        let args = CommandLine.arguments
        return processArgs(args: args)
    }
    
    public func processArgs(args:[String]) -> [String:SimpleType]{
        var values = [String:SimpleType]()
        var index = 1
        let count = args.count
        while ( index < count ){
            let arg = args[index]
            let first = arg.startIndex
            let char = arg[first]
            if char == "-" {
                let key = arg.substring(from: arg.index(first, offsetBy: 1))
                if (index + 1 >= count ){
                    values[key] = .NULL
                    break
                }
                let val = args[index + 1]
                if (val == "-") {
                    values[key] = .NULL
                }
                else {
                    values[key] = resolveType(key: key, val:val)
                    index += 1
                }
            }
            index += 1
        }
        return values
    }
    
    private func resolveType(key:String, val: String) -> SimpleType {
        if let type = self.config?.getTypeInfo(option: key) {
            return SimpleType.fromType(type: type, value:val)
        }
        return SimpleType.fromString(value: val)
    }
    
    private func getPrefixLength(s:String) -> Int? {
        if ( s == "-" ){
            return 1
        }
        if ( s == "--" ){
            return 2
        }
        return nil
    }
}
