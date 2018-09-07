//
//  LocalRepository.swift
//  news
//
//  Created by mac2 on 9/4/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit

class LocalRepository {

    func saveArticles(articles: [Article]) {
        UserPreferences().articles = articles
    }
    
    func getArticles() -> [Article] {
        return UserPreferences().articles ?? []
    }
    
}
