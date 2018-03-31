//
//  HttpClient.swift
//  WibrTools
//
//  Created by Winfried Brinkhuis on 23-03-18.
//

import Foundation

public struct HttpError : LocalizedError, CustomStringConvertible  {
    
    var status: Int
    var data: Data?
    
   public init(status: Int, data: Data?){
        self.status = status
        self.data = data
    }
    public var description: String {
        if let ed = errorDescription {
            return ed
        }
        return "[status: \(self.status)] - no data"
    }
    
    public var errorDescription: String? {
        var r = "[status: \(status)]"
        if let d = self.data, let s = d.utf8String {
            r = "\(r) - \(s)"
        }
        return r
    }
}

public struct HttpResponse {
    let status: Int
    let data: Data?
    
    init(status:Int, data:Data?){
        self.status = status
        self.data = data
    }
}

public enum RequestError: Error {
    case invalidURL(String)
    case invalidData(String)
}

public enum ResponseError: Error {
    case RequestFailed(Error)
    case noData
    case invalidRequest(Int)
    case parsingError(String)
    case fatal(String)
//    case withData(HttpError)
}

public protocol RequestSender {
    var debug: Bool {get set}
    func send( url:URL, method:HttpMethod, requestHeaders:[String:String]?, body:Data?, completion: @escaping (Result<HttpResponse>) -> ())
}

private class NoopRequestSender : NSObject, URLSessionDelegate, RequestSender  {
    var requestTimeout = 30.0
    var resourceTimeout = 60.0
    var debug = false
    
    init(requestTimeout: Double, resourceTimeout : Double ){
        self.requestTimeout = requestTimeout
        self.resourceTimeout = resourceTimeout
    }
    
    func send(url: URL, method: HttpMethod, requestHeaders: [String : String]?, body: Data?, completion: @escaping (Result<HttpResponse>) -> ()) {
    }
    
    func createSessionConfiguration(_ additionalHeaders:[AnyHashable: Any] = [:]) -> URLSessionConfiguration{
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = self.requestTimeout
        sessionConfig.timeoutIntervalForResource = self.resourceTimeout
        if additionalHeaders.count > 0 {
            sessionConfig.httpAdditionalHeaders = additionalHeaders
        }
        return sessionConfig
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?){
        
    }
    
    func processResponseData(data: Data?, statusCode: Int) -> Result<HttpResponse>{
        guard let responseData = data else {
            return Result.failure(ResponseError.noData)
        }
        if statusCode >= 400 {
            return Result.failure(HttpError(status: statusCode, data: data))
        }
        return Result.success(HttpResponse(status: statusCode, data: responseData))
    }
    
    func debug(data: Data?) {
        if self.debug, let data = data, let str = String(data:data, encoding:.utf8) {
            print(str)
        }
    }
    
    func prepareRequest(url:URL, method:HttpMethod, requestHeaders:[String:String]?, body:Data?) -> (session:URLSession, request:URLRequest){
        let sessionConfig = createSessionConfiguration()
        let session = URLSession(configuration: sessionConfig, delegate:self, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = requestHeaders
        request.httpMethod = method.rawValue
        if let b = body {
            request.httpBody = b
        }
        return (session, request)
    }
    
    func processResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<HttpResponse> {
        self.debug(data: data)
        return Result {
            if let err = error { throw err }
            guard let r = response as? HTTPURLResponse else {
                throw ResponseError.fatal("URLResponse not of expected type HTTPURLResponse but of actual-type: \(String(describing: response.self))")
            }
            let result = self.processResponseData(data: data, statusCode: r.statusCode)
            return try result.resolve()
        }
    }
}

private class SyncSender : NoopRequestSender {
    override func send(url: URL, method: HttpMethod, requestHeaders: [String : String]?, body: Data?, completion: @escaping (Result<HttpResponse>) -> ()){
        let preparation = self.prepareRequest(url: url, method: method, requestHeaders: requestHeaders, body: body)
        let task = preparation.session.synchronousDataTask(urlrequest: preparation.request)
        let result = self.processResponse(data: task.data, response: task.response, error: task.error)
        completion(result)
    }
}

private class AsyncSender : NoopRequestSender {
    override func send(url: URL, method: HttpMethod, requestHeaders: [String : String]?, body: Data?, completion: @escaping (Result<HttpResponse>) -> ()){
        let preparation = self.prepareRequest(url: url, method: method, requestHeaders: requestHeaders, body: body)
        let task = preparation.session.dataTask(with: preparation.request as URLRequest, completionHandler: { (data, response, error) -> Void in
            let result = self.processResponse(data: data, response: response, error: error)
            completion(result )
        })
        task.resume()
    }
}

public class HttpClient {
    private var requestSender: RequestSender
    var _debug = false
    init(requestSender : RequestSender){
        self.requestSender = requestSender
    }
    
    public var debug : Bool {
        get { return _debug }
        set {
            self._debug = newValue
            self.requestSender.debug = self._debug
        }
    }
    
    public func get(url:String,
                       requestHeaders:[String:String] = [String:String](),
                       _ resultHandler: @escaping (Result<HttpResponse>) -> ()) {
        self.send(url:url,
                  requestHeaders:requestHeaders,
                  body: nil,
                  method:.GET,
                  resultHandler)
    }
    
    public func post(url:String,
                        requestHeaders:[String:String] = [String:String](),
                        body:Data?,
                        _ resultHandler: @escaping (Result<HttpResponse>) -> ()) {
        self.send(url: url,
                  requestHeaders:requestHeaders,
                  body: body,
                  method: .POST,
                  resultHandler)
    }
    
    public func put(url:String,
                       requestHeaders:[String:String] = [String:String](),
                       body:Data?,
                       _ resultHandler: @escaping (Result<HttpResponse>) -> ()) {
        self.send(url: url,
                  requestHeaders:requestHeaders,
                  body: body,
                  method: .PUT,
                  resultHandler)
    }
    
    public func delete(url:String,
                          requestHeaders:[String:String] = [String:String](),
                          _ resultHandler: @escaping (Result<HttpResponse>) -> ()) {
        self.send(url: url,
                  requestHeaders:requestHeaders,
                  body: nil,
                  method: .DELETE,
                  resultHandler)
    }
    
    public func send(url:String,
                        requestHeaders:[String:String] = [String:String](),
                        body:Data?,
                        method: HttpMethod,
                        _ resultHandler: @escaping (Result<HttpResponse>) -> ()) {
        guard let _url = URL(string: url) else { resultHandler(Result.failure(RequestError.invalidURL(url))); return }
        self.requestSender.send(url: _url, method:method, requestHeaders:requestHeaders, body: body,completion: resultHandler)
    }
}

extension HttpClient {
    
    public static func AsyncInstance(requestTimeout: Double = 30.0, resourceTimeout: Double = 60.0) -> HttpClient {
        let requestSender = AsyncSender(requestTimeout: requestTimeout, resourceTimeout: resourceTimeout)
        return HttpClient(requestSender: requestSender)
    }
    
    public static func SyncInstance(requestTimeout: Double = 30.0, resourceTimeout: Double = 60.0) -> HttpClient {
        let requestSender = SyncSender(requestTimeout: requestTimeout, resourceTimeout: resourceTimeout)
        return HttpClient(requestSender: requestSender)
    }
    
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}


