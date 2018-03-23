//
//  SimpleHttp.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 05-03-17.
//
//

import Foundation

public enum HttpMethod : String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case OPTIONS = "OPTIONS"
}

public struct ResourceHelper {
    public static func jsonArray<A>( _ transform: @escaping (Any) -> A?) -> (Any) ->[A]? {
        return { array in
            guard let array = array as? [Any] else {
                return nil
            }
            return array.flatMap(transform)
        }
    }
    
    public static func toString(any:Any) -> String? {
        return "\(any)"
    }
    
    public static func handleError(error:Error, response:HTTPURLResponse){
        
    }
    
}

public struct Resource<A> {
    let path:String
    let parse: (Any) -> A?
    var errorHandler: ((Error,HTTPURLResponse) -> Void)? = ResourceHelper.handleError
    var requestHeaders: [String:String]?
    var method:HttpMethod = HttpMethod.GET
    var body: Data?
    var requestTimeout:Double = 30.0
    var resourceTimeout:Double = 60.0
    
    
    init(path:String, method:HttpMethod = .GET, body:Data? = nil, errorHandler:((Error,HTTPURLResponse) -> Void)? = ResourceHelper.handleError, parse:@escaping (Any) ->A?){
        self.path = path
        self.method = method
        self.parse = parse
        self.body = body
        self.errorHandler = errorHandler
    }
}

extension Resource {
    func loadAsynchronously(baseUrl url: URL, callback: @escaping(A?) -> ()) {
        let resourceUrl = url.appendingPathComponent(path)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = self.requestTimeout
        sessionConfig.timeoutIntervalForResource = self.resourceTimeout
        let session = URLSession(configuration: sessionConfig)
        var request = URLRequest(url: resourceUrl)
        if let rh = self.requestHeaders {
            request.allHTTPHeaderFields = rh
        }
        request.httpMethod = method.rawValue
        if let b = self.body {
            request.httpBody = b
        }
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if let err = error {
                self.errorHandler?(err, response as! HTTPURLResponse)
            }
            else {
                let json = data.flatMap{
                    try? JSONSerialization.jsonObject(with: $0, options: [])
                }
                callback(json.flatMap(self.parse))
            }
        })
        task.resume()
    }
}

struct Message {
    let type: String?
    let code: String?

    init?(dict:Any){
        guard let d = dict as? [String:Any] else {
            return nil
        }
        self.type = d["type"] as! String?
        self.code = d["code"] as! String?
    }
}



struct Demo {
    let url = URL(string: "http://localhost:8080/message")!
    let listMessages = Resource(path: "", parse: ResourceHelper.toString)
    
    public func send() {
        listMessages.loadAsynchronously(baseUrl: url) { (item) in
            print(item ?? "--")
        }
    }
}
