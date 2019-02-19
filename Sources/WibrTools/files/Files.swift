import Foundation

public struct Files {
    public static func readFile(name:String) -> String? {
        guard Files.fileExists(name: name) else {
            print("File \(name) not Found")
            return nil
        }
        do {
            return try String(contentsOfFile: name, encoding: String.Encoding.utf8)
        } catch(let error){
            print(error)
            return nil
        }
    }
    
    public static func fileExists(name:String) -> Bool {
        let filemgr = FileManager.default
        return filemgr.fileExists(atPath: name)
    }
    
}

public struct FileWalker {
    public enum FileType {
        case File
        case Directory
    }
    let rootDir:String
    let filemgr:FileManager
    
    public init(rootDir:String){
        self.rootDir = rootDir
        self.filemgr = FileManager.default
    }
    
    public func collecFiles(all recursive: Bool = false, _ callback:(String,FileType) -> ()) {
        self.collectFiles(path: self.rootDir, true, recursive, callback: callback)
    }
    
    private func collectFiles(path: String, _ first: Bool, _ recursive:Bool, callback: (String, FileType) -> ()){
        var dir:ObjCBool = ObjCBool(false)
        if self.filemgr.fileExists(atPath: path, isDirectory: &dir) {
            if dir.boolValue {
                callback(path, .Directory)
                if first || recursive {
                    if let contents = try? self.filemgr.contentsOfDirectory(atPath: path){
                        for file in contents {
                            let sub = "\(path)/\(file)"
                            collectFiles(path: sub, false, recursive, callback: callback)
                        }
                    }
                }
            }
            else {
                callback(path, .File)
            }
        }
    }
}

public struct FileInfo : Codable, CustomStringConvertible {
    public let path:[String]?
    public let filename: String
    public let fileext: String?
    
    public init(path:[String]?, filename: String, fileext:String?){
        self.path = path
        self.filename = filename
        self.fileext = fileext
    }
    
    public init(name: String){
        var value = name;
        let parts = value.components(separatedBy: "/")
        if parts.count == 1 {
            self.path = nil
        }
        else {
            self.path = Array(parts.dropLast())
            value = parts.last!
        }
        if let period = value.lastIndex(of: "."){
            self.filename = String(value[..<period])
            self.fileext = String(value[value.index(after: period)...])
        }
        else {
            self.filename = String(value)
            self.fileext = nil
        }
    }
    
    public var pathIsAbsolute : Bool {
        if let first = self.path?.first, first == "" {
            return true
        }
        return false
    }
    
    public var fullFilename : String {
        var result = self.filename
        if let ext = self.fileext {
            result += "." + ext
        }
        return result
    }
    
    public var description: String{
        var result = ""
        if let path = self.path {
            result += path.joined(separator: "/") + "/"
        }
        result += self.fullFilename
        return result
    }
}

extension FileInfo : ExpressibleByStringLiteral{
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}
