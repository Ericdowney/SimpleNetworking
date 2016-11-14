//
//  Service.swift
//  SimpleNetworking
//
//  Created by Downey, Eric on 10/20/16.
//  Copyright © 2016 Eric Downey. All rights reserved.
//

import Foundation

/// Trait style protocol for requesting a data task with a URLRequest and a completion block
public protocol UrlRequester {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

/// Retroactive Modeling so URLSession now conforms to URLRequester trait
extension URLSession: UrlRequester {}

/// Trait style protocol to replace DispatchQueue static call
public protocol Synchronizer {
    func sync(execute block: (Void) -> Void)
}

/// Retroactive modeling so DispatchQueue is a Synchronizer
extension DispatchQueue: Synchronizer {}

/// Error enum with one case for a bad url
public enum ServiceError: Error {
    case BadUrl
}

/// Interface style protocol to describe a service object
public protocol Service {
    init(urlRequester: UrlRequester, synchronizer: Synchronizer)
    func requestData<T>(from urlString: String, usingMap map: @escaping (Data?) -> T?, withCompletion completion: @escaping (T?) -> Void) throws
    func requestData<T>(from urlRequest: URLRequest, usingMap map: @escaping (Data?) -> T?, withCompletion completion: @escaping (T?) -> Void) throws
    
    func requestData(from urlString: String, withCompletion completion: @escaping (Data?) -> Void) throws
    func requestData(from urlRequest: URLRequest, withCompletion completion: @escaping (Data?) -> Void) throws
}

/// Implements an object that conforms to the Service protocol
open class DataService: Service {
    var urlRequester: UrlRequester
    var synchronizer: Synchronizer
    
    required public init(urlRequester: UrlRequester = URLSession.shared, synchronizer: Synchronizer = DispatchQueue.main) {
        self.urlRequester = urlRequester
        self.synchronizer = synchronizer
    }
}

public extension DataService {
    /// Get data (T) from a url string and map data to type (T) with completion block. Throws a BadUrl ServiceError
    func requestData<T>(from urlString: String, usingMap map: @escaping (Data?) -> T?, withCompletion completion: @escaping (T?) -> Void) throws {
        guard let url = URL(string: urlString) else {
            throw ServiceError.BadUrl
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 12.0)
        let task = urlRequester.dataTask(with: request) { [weak self] data, _, _ in
            self?.synchronizer.sync {
                completion( map( data ) )
            }
        }
        task.resume()
    }
    
    /// Get data (T) from a url request and map data to type (T) with completion block. Throws a BadUrl ServiceError
    func requestData<T>(from urlRequest: URLRequest, usingMap map: @escaping (Data?) -> T?, withCompletion completion: @escaping (T?) -> Void) throws {
        let task = urlRequester.dataTask(with: urlRequest) { [weak self] data, _, _ in
            self?.synchronizer.sync {
                completion( map( data ) )
            }
        }
        task.resume()
    }
}

public extension DataService {
    // MARK: - Request with URL String
    
    func requestData(from urlString: String, withCompletion completion: @escaping (Data?) -> Void) throws {
        try? requestData(from: urlString, usingMap: {$0}, withCompletion: completion)
    }
    
    // MARK: - Request with URL Request object
    
    func requestData(from urlRequest: URLRequest, withCompletion completion: @escaping (Data?) -> Void) throws {
        try? requestData(from: urlRequest, usingMap: {$0}, withCompletion: completion)
    }
}

