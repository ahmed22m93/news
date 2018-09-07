//
//  RemoteRepository.swift
//  news
//
//  Created by mac2 on 9/4/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit
import Moya

protocol ReomteHeadLines {
    func getHeadlines(countryCode: String, page: Int, pageSize: Int, handler:@escaping (TopHeadlines?,APIError?)->Void)
}

class RemoteRepository: ReomteHeadLines {
    
    let headlinesContentProvider = MoyaProvider<HeadlinesContent>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    func getHeadlines(countryCode: String, page: Int, pageSize: Int = 10, handler: @escaping (TopHeadlines?, APIError?) -> Void) {
        headlinesContentProvider.request(HeadlinesContent.getTopHeadlines(CountryCode: countryCode, Page: page, PageSize: pageSize)) { (result) in
            
            switch result {
            case .success:
                guard let value = result.value else{
                    handler(nil,APIError(code: "-1", messages: "Unexpected Error"))
                    return
                }
                
                let resultData = value.data
                if APIError.isErrorObject(object: resultData){
                    handler(nil,APIError(object: resultData))
                }else{
                    handler(TopHeadlines(object: value.data),nil)
                }
                
            case .failure(let error):
                let errorCode = error.response?.statusCode ?? -1009
                let apiError = APIError(code: String(errorCode), messages: error.localizedDescription)
                handler(nil,apiError)
            }
        }
    }
    
}
