//
//  Service+Image.swift
//  SimpleNetworking
//
//  Created by Downey, Eric on 10/20/16.
//  Copyright © 2016 Eric Downey. All rights reserved.
//

import Foundation

/// Trait style protocol to describe requesting json via a url with a completion block
public protocol ImageData {
    func requestImage(from urlString: String, withCompletion completion: @escaping (UIImage?) -> Void) throws
    func requestImage(from urlRequest: URLRequest, withCompletion completion: @escaping (UIImage?) -> Void) throws
}

/// Extension constrained to Service types that automatically fetches data and converts it to the JSON type
public extension ImageData where Self: Service {
    
    // MARK: - Request with URL String
    
    func requestImage(from urlString: String, withCompletion completion: @escaping (UIImage?) -> Void) throws {
        try? requestData(from: urlString, usingMap: convertToImage, withCompletion: completion)
    }
    
    // MARK: - Request with URL Request object
    
    func requestImage(from urlRequest: URLRequest, withCompletion completion: @escaping (UIImage?) -> Void) throws {
        try? requestData(from: urlRequest, usingMap: convertToImage, withCompletion: completion)
    }
    
    private func convertToImage(from data: Data?) -> UIImage? {
        guard let d = data else {
            return nil
        }
        return UIImage(data: d)
    }
}

/// Retroactive Modeling so BaseService objects conform to JSONData trait
extension DataService: ImageData {}
