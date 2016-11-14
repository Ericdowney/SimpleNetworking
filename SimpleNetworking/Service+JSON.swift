//
//  Service+JSON.swift
//  SimpleNetworking
//
//  Created by Downey, Eric on 10/20/16.
//  Copyright © 2016 Eric Downey. All rights reserved.
//

import Foundation

/// Trait style protocol to describe requesting json via a url with a completion block
public protocol JSONData {
    func requestJSON(from urlString: String, withCompletion completion: @escaping (JSON?) -> Void) throws
    func requestJSON(from urlString: String, withCompletion completion: @escaping (Mapper?) -> Void) throws
    
    func requestJSON(from urlRequest: URLRequest, withCompletion completion: @escaping (JSON?) -> Void) throws
    func requestJSON(from urlRequest: URLRequest, withCompletion completion: @escaping (Mapper?) -> Void) throws
}

/// Extension constrained to Service types that automatically fetches data and converts it to the JSON type
public extension JSONData where Self: Service {
    
    // MARK: - Request with URL String
    
    func requestJSON(from urlString: String, withCompletion completion: @escaping (JSON?) -> Void) throws {
        try? requestData(from: urlString, usingMap: convertToJSON, withCompletion: completion)
    }
    
    func requestJSON(from urlString: String, withCompletion completion: @escaping (Mapper?) -> Void) throws {
        try? requestData(from: urlString, usingMap: { Mapper(value: self.convertToJSON(from: $0) ) }, withCompletion: completion)
    }
    
    // MARK: - Request with URL Request object
    
    func requestJSON(from urlRequest: URLRequest, withCompletion completion: @escaping (JSON?) -> Void) throws {
        try? requestData(from: urlRequest, usingMap: convertToJSON, withCompletion: completion)
    }
    
    func requestJSON(from urlRequest: URLRequest, withCompletion completion: @escaping (Mapper?) -> Void) throws{
        try? requestData(from: urlRequest, usingMap: { Mapper(value: self.convertToJSON(from: $0) ) }, withCompletion: completion)
    }
    
    private func convertToJSON(from data: Data?) -> JSON? {
        guard let d = data else {
            return nil
        }
        do {
            return try JSONSerialization.jsonObject(with: d, options: .allowFragments) as? JSON
        }
        catch {
            return nil
        }
    }
}

/// Retroactive Modeling so BaseService objects conform to JSONData trait
extension DataService: JSONData {}
