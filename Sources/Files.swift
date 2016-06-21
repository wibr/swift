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
        let filemgr = FileManager.default()
        return filemgr.fileExists(atPath: name)
    }
    
}

public struct FileWalker {
    
    let rootDir:String
    let filemgr:FileManager
    
    init(rootDir:String){
        self.rootDir = rootDir
        self.filemgr = FileManager.default()
    }
    
    func collectFiles(callback: (String, String) -> Void ){
        // TODO: create implementation
        callback(self.rootDir,self.rootDir)
    }
}
