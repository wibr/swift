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
