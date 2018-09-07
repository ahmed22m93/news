//
//  TopHeadlines.swift
//
//  Created by mac2 on 9/4/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class TopHeadlines: NSObject, NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let status = "status"
    static let totalResults = "totalResults"
    static let articles = "articles"
  }

  // MARK: Properties
  public var status: String?
  public var totalResults: Int?
  public var articles: [Article]?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    status = json[SerializationKeys.status].string
    totalResults = json[SerializationKeys.totalResults].int
    if let items = json[SerializationKeys.articles].array { articles = items.map { Article(json: $0) } }
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = totalResults { dictionary[SerializationKeys.totalResults] = value }
    if let value = articles { dictionary[SerializationKeys.articles] = value.map { $0.dictionaryRepresentation() } }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.status = aDecoder.decodeObject(forKey: SerializationKeys.status) as? String
    self.totalResults = aDecoder.decodeObject(forKey: SerializationKeys.totalResults) as? Int
    self.articles = aDecoder.decodeObject(forKey: SerializationKeys.articles) as? [Article]
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(status, forKey: SerializationKeys.status)
    aCoder.encode(totalResults, forKey: SerializationKeys.totalResults)
    aCoder.encode(articles, forKey: SerializationKeys.articles)
  }

}
