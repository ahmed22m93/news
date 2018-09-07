//
//  HeadlinesAPI.swift
//  news
//
//  Created by mac2 on 9/4/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import Foundation
import Moya

public enum HeadlinesContent {
    case getTopHeadlines(CountryCode: String, Page: Int, PageSize: Int)
}

extension HeadlinesContent: TargetType {
    public var baseURL: URL { return URL(string: "https://newsapi.org/v2")! }
    
    public var path: String {
        switch self {
        case .getTopHeadlines(_,_,_):
            return "/top-headlines"
        }
    }
    
    public var method: Moya.Method {
            return .get
    }
    
    public var task: Task {
        switch self {
        case .getTopHeadlines(CountryCode: let countryCode, Page: let page, PageSize: let pageSize):
            return .requestParameters(parameters: ["country": countryCode,"page": page,"pageSize": pageSize, "apiKey": top_headlines_api_key], encoding: URLEncoding.default)
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .getTopHeadlines(_,_,_):
            return "{\"status\": ok, \"totalResults\": 20, \"articles\": [{\"source\":{\"id\":\"the-new-york-times\",\"name\":\"The New York Times\"},\"author\":\"http://www.nytimes.com/by/cecilia-kang\",\"title\":\"Facebook and Twitter Have a Message for Lawmakers: We're Trying\",\"description\":\"In testimony prepared ahead of congressional hearings on Wednesday, Facebook and Twitter displayed a conciliatory approach over issues like disinformation and manipulation.\",\"url\":\"https://www.nytimes.com/2018/09/04/technology/facebook-and-twitter-have-a-message-for-lawmakers-were-trying.html\",\"urlToImage\":\"https://static01.nyt.com/images/2018/09/05/business/05TECHHEARING-2/05TECHHEARING-2-facebookJumbo.jpg\",\"publishedAt\":\"2018-09-04T19:55:16Z\"}]}".data(using: .utf8)!
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

