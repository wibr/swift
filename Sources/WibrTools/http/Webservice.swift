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
    let data: Data?
    
    init(statusCode:Int, data: Data?, cause: Error?){
        self.statusCode = statusCode
        self.data = data
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
    var payload: Data?
    
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

public typealias ResponseDebugger = (HTTPURLResponse, Data?, Error?) -> ()

public class Sender {
    let baseUrl: String?
    let requestTimeout: Double
    let resourceTimeout: Double
    let responseDebugger: ResponseDebugger?
    
    init(config:WebserviceConfig){
        self.requestTimeout = config.requestTimeout
        self.resourceTimeout = config.resourceTimeout
        self.responseDebugger = config.responseDebugger
        self.baseUrl = config.baseUrl
    }
    
    public func send<A>(resource:Resource<A>, completion: @escaping( Result<HttpSuccessResponse<A>> ) -> ()) {
    }
    
    func prepareRequest<A>(resource:Resource<A>) -> (session: URLSession, request: URLRequest)? {
        let base = self.baseUrl ?? ""
        guard let url = URL(string: base + resource.path) else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        if let rh = resource.requestHeaders {
            urlRequest.allHTTPHeaderFields = rh
        }
        urlRequest.httpMethod = resource.method.rawValue
        if let payload = resource.payload {
            urlRequest.httpBody = payload
        }
        let sessionConfig = createSessionConfiguration(resource.requestHeaders)
        let urlSession = URLSession(configuration: sessionConfig)
        return (urlSession, urlRequest)
    }
    
    func handleResponse<A>(resource:Resource<A>, data: Data?, response: URLResponse?, error: Error?, completion: @escaping( Result<HttpSuccessResponse<A>> ) -> ()){
        guard let r = response as? HTTPURLResponse else {
            completion(Result.failure(ResponseError.fatal("URLResponse not of expected type HTTPURLResponse but of actual-type: \(String(describing: response.self))")))
            return
        }
        self.responseDebugger?(r, data, error)
        let statusCode = r.statusCode
        if let err = error {
            completion(HttpErrorResponse(statusCode: statusCode, data: data, cause: err).failure())
        }
        else if let d = data {
            if let obj = resource.parse(d){
                completion(Result.success(HttpSuccessResponse(statusCode: statusCode, value: obj)))
            }
            else {
                let message = "Unable to parse data into expected object: \(type(of:resource.parse))"
                let hre = HttpErrorResponse(statusCode: statusCode, data: data, cause: ResponseError.parsingError(message) )
                completion(hre.failure())
            }
        }
    }
    
    func createSessionConfiguration(_ additionalHeaders:[AnyHashable: Any]?) -> URLSessionConfiguration{
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = self.requestTimeout
        sessionConfig.timeoutIntervalForResource = self.resourceTimeout
        if let ah = additionalHeaders, ah.count > 0 {
            sessionConfig.httpAdditionalHeaders = ah
        }
        return sessionConfig
    }
}

class ASynchronousSender : Sender {
    override func send<A>(resource:Resource<A>, completion: @escaping( Result<HttpSuccessResponse<A>> ) -> ()) {
        guard let prepared = prepareRequest(resource: resource) else {
            return
        }
        let task = prepared.session.dataTask(with: prepared.request as URLRequest, completionHandler: { (data, response, error) in
            self.handleResponse(resource: resource, data: data, response: response, error: error, completion: completion)
        })
        task.resume()
    }
}
class SynchronousSender : Sender {
    override func send<A>(resource:Resource<A>, completion: @escaping( Result<HttpSuccessResponse<A>> ) -> ()) {
        guard let prepared = prepareRequest(resource: resource) else {
            return
        }
        let task = prepared.session.synchronousDataTask(urlrequest: prepared.request)
        let response = task.response
        let data = task.data
        let error = task.error
        self.handleResponse(resource: resource, data: data, response: response, error: error, completion: completion)
    }
}

public struct WebserviceConfig {
    let baseUrl: String?
    let requestTimeout: Double
    let resourceTimeout: Double
    public var responseDebugger: ResponseDebugger?

    public init(baseUrl:String, requestTimeout: Double = 30.0, resourceTimeout: Double = 60.0){
        self.baseUrl = baseUrl
        self.requestTimeout = requestTimeout
        self.resourceTimeout = resourceTimeout
    }
    
    public static func defaultConfig() -> WebserviceConfig {
        return WebserviceConfig(baseUrl:"")
    }
    
}

public class Webservice {
    let sender: Sender
    var config: WebserviceConfig
    
    init(config:WebserviceConfig, sender:Sender){
        self.config = config
        self.sender = sender
    }
}

extension Webservice {
    public static func asyncInstance(config: WebserviceConfig)-> Webservice {
        let sender = ASynchronousSender(config:config)
        return Webservice(config: config, sender: sender)
    }
    
    public static func syncInstance(config: WebserviceConfig)-> Webservice {
        let sender = SynchronousSender(config:config)
        return Webservice(config: config, sender: sender)
    }
}
