//
//  APIError.swift
//
//  Created by mac2 on 9/4/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct APIError {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let status = "status"
        static let code = "code"
        static let message = "message"
    }
    
    // MARK: Properties
    public var status: String?
    public var code: String?
    public var message: String?
    
    // MARK: SwiftyJSON Initializers
    /// Initiates the instance based on the object.
    ///
    /// - parameter object: The object of either Dictionary or Array kind that was passed.
    /// - returns: An initialized instance of the class.
    public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    init(status: String = "error", code: String, messages: String) {
        self.status = status
        self.code = code
        self.message = messages
    }
    
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        code = json[SerializationKeys.code].string
        message = json[SerializationKeys.message].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = code { dictionary[SerializationKeys.code] = value }
        if let value = message { dictionary[SerializationKeys.message] = value }
        return dictionary
    }
    
}

extension APIError {
    
    static func isErrorObject(object: Any) -> Bool {
        let json = JSON(object)
        if let status = json[SerializationKeys.status].string, status == "error" {
            return true
        }
        return false
    }
}
