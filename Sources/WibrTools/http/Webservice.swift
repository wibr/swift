//
//  SimpleHttp.swift
//  WibrTools
//
//  Created by winfried brinkhuis on 05-03-17.
//
//

import Foundation

public struct HttpSuccessResponse<A> : CustomStringConvertible{
    let statusCode: Int
    let value: A
    
    init(statusCode: Int, value: A){
        self.statusCode = statusCode
        self.value = value
    }
    
    public var description: String {
        return "HttpResponse(status-code: \(self.statusCode), value:\(type(of:self.value)))"
    }
    
}

public struct HttpErrorResponse : Error {
    let statusCode: Int
    let cause: Error?
    
    init(statusCode:Int, cause: Error? = nil){
        self.statusCode = statusCode
        self.cause = cause
    }
    
}

public enum HttpMethod : String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case OPTIONS = "OPTIONS"
}

public struct Resource<A> {
    let path: String
    let parse: (Data) -> A?
    var requestHeaders: [String:String]?
    var method:HttpMethod = HttpMethod.GET
    var body: Data?
    
    init(path:String, method:HttpMethod = .GET, parse: @escaping (Data) -> A?){
        self.path = path
        self.method = method
        self.parse = parse
    }
    
}

extension Resource  {
    init(path:String, method:HttpMethod = .GET, parseJson: @escaping (Any) -> A? ){
        self.path = path
        self.method = method
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJson)
        }
    }
}

extension Resource where A : Decodable {
    init(path:String, method:HttpMethod = .GET) {
        self.path = path
        self.method = method
        self.parse = { data in
            return try? JSONDecoder().decode(A.self, from: data)
        }
    }
}

public class Webservice {
    let requestTimeout: Double
    let resourceTimeout: Double
    let baseUrl: String
    
    public init(baseUrl: String, requestTimeout:Double = 30.0, resourceTimeout:Double = 60.0 ){
        self.baseUrl = baseUrl
        self.requestTimeout = requestTimeout
        self.resourceTimeout = resourceTimeout
    }
    
    public func send<A>(resource:Resource<A>, completion: @escaping( Result<HttpSuccessResponse<A>> ) -> ()) {
        guard let url = URL(string: self.baseUrl + resource.path) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        if let rh = resource.requestHeaders {
            urlRequest.allHTTPHeaderFields = rh
        }
        urlRequest.httpMethod = resource.method.rawValue
        let sessionConfig = createSessionConfiguration(resource.requestHeaders)
        let session = URLSession(configuration: sessionConfig)
        if let b = resource.body {
            urlRequest.httpBody = b
        }
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: { (data, response, error) in
            guard let r = response as? HTTPURLResponse else {
                completion(Result.failure(ResponseError.fatal("URLResponse not of expected type HTTPURLResponse but of actual-type: \(String(describing: response.self))")))
                return
            }
            
            let statusCode = r.statusCode
            if let err = error {
                completion(HttpErrorResponse(statusCode: statusCode, cause: err).failure())
            }
            else if let d = data {
                if let obj = resource.parse(d){
                    completion(Result.success(HttpSuccessResponse(statusCode: statusCode, value: obj)))
                }
                else {
                    let message = "Unable to parse data into expected object: \(type(of:resource.parse))"
                    let hre = HttpErrorResponse(statusCode: statusCode, cause: ResponseError.parsingError(message) )
                    completion(hre.failure())
                }
            }
        })
        task.resume()
    }
    
    private func createSessionConfiguration(_ additionalHeaders:[AnyHashable: Any]?) -> URLSessionConfiguration{
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = self.requestTimeout
        sessionConfig.timeoutIntervalForResource = self.resourceTimeout
        if let ah = additionalHeaders, ah.count > 0 {
            sessionConfig.httpAdditionalHeaders = ah
        }
        return sessionConfig
    }
}
