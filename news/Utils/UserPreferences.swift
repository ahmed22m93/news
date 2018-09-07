//
//  UserPreferences.swift
//  news
//
//  Created by mac2 on 9/4/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit

class UserPreferences {

    private struct Preferenceskeys {
        static let articles = "articles"
    }
    
    var articles: [Article]? {
        get {
            if let encodedArray = UserDefaults.standard.object(forKey: Preferenceskeys.articles) as? Data {
                if let decodedArray =  NSKeyedUnarchiver.unarchiveObject(with: encodedArray) as! [Article]? {
                    return decodedArray
                }
            }
            return nil
        }
        set {
            if let articles = newValue{
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: articles)
                UserDefaults.standard.set(encodedData, forKey: Preferenceskeys.articles)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
}
