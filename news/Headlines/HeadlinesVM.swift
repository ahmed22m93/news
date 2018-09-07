//
//  HeadlinesVM.swift
//  news
//
//  Created by mac2 on 9/6/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit
import Reachability

protocol HeadLinesView {
    func startWindlessLoader()
    func endWindlessLoader()
    func endRefreshLoader()
    
    func reloadData()
    func showMsg(msg: String?)
    
}

class HeadlinesVM: NSObject {

    private let dataManager = DataManager()
    private var view: HeadLinesView
    private var articles = [Article]()
    {
        didSet{
            if oldValue.count == filteredArticles.count {
                self.filteredArticles = articles
            }
        }
    }
    private var filteredArticles = [Article]()
    
    private var isFirstLoad = true
    private var isDumyData = true
    private var totalResultNeeds = 0
    private var countryCode: String = ""
    
    private var reachability = Reachability()!
    
    init(view: HeadLinesView) {
        self.view = view
        
        super.init()
//        self.reachabilityLisiter()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    
    private func getCountryCode() -> String{
        return NSLocale.deviceCountryCode
    }
    
    private func getNextPage() -> Int{
        return Int(ceil(Double(self.articles.count / 10)) + 1)
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
//        reachability.stopNotifier()
    }
    
}

extension HeadlinesVM {
    
    
    func getFirstHeadLines(){
        
        self.countryCode = self.getCountryCode()
        view.startWindlessLoader()
        
        self.loadHeadLines(ofCounrty: self.countryCode, page: 1) { (topHeadlines, error) in
            
            if let topHeadlines = topHeadlines, let totalResult = topHeadlines.totalResults, let articles = topHeadlines.articles{
                
                if totalResult == 0 {
                    self.countryCode = "US"
                    self.loadHeadLines(ofCounrty: self.countryCode, page: 1, complition: { (topHeadlines, error) in
                        
                        if let topHeadlines = topHeadlines, let totalResult = topHeadlines.totalResults, let articles = topHeadlines.articles{
                            
                            self.firstLoadDone(withData: articles, totalResult: totalResult)
                            
                        }else if let error = error {
                            self.view.showMsg(msg: error.message)
                            self.articles = self.dataManager.local.getArticles()
                            self.isDumyData = false
                            self.view.reloadData()
                        }
                        
                        self.view.endWindlessLoader()
                    })
                    
                }else{
                    self.firstLoadDone(withData: articles, totalResult: totalResult)
                    self.view.endWindlessLoader()
                }
                
            }else if let error = error {
                self.view.showMsg(msg: error.message)
                self.articles = self.dataManager.local.getArticles()
                self.isDumyData = false
                self.view.reloadData()
                self.view.endWindlessLoader()
            }
            
        }
        
    }
    
    private func firstLoadDone(withData articles: [Article], totalResult: Int){
        self.totalResultNeeds = totalResult
        self.articles = articles
        self.dataManager.local.saveArticles(articles: Array(articles.prefix(5)))
        self.isDumyData = false
        self.isFirstLoad = false
        self.view.reloadData()
    }
    
    func refreshHeadlines(){
        
        self.loadHeadLines(ofCounrty: self.countryCode, page: 1) { (topHeadlines, error) in
            
            if let topHeadlines = topHeadlines, let totalResult = topHeadlines.totalResults, let articles = topHeadlines.articles{
                
                self.firstLoadDone(withData: articles, totalResult: totalResult)
                
            }else if let error = error {
                self.view.showMsg(msg: error.message)
            }
            
            self.view.endRefreshLoader()
        }
        
    }
    
    func loadMoreHeadLines(){
        
        guard articles.count < totalResultNeeds else {
            return
        }
        
        let nextPage = self.getNextPage()
        self.loadHeadLines(ofCounrty: self.countryCode, page: nextPage) { (topHeadlines, error) in
            
            if let topHeadlines = topHeadlines, let articles = topHeadlines.articles{
                
                self.articles.append(contentsOf: articles)
                self.view.reloadData()
                
            }else if let error = error {
                self.view.showMsg(msg: error.message)
            }

        }
        
    }
    
    private func loadHeadLines(ofCounrty countryCode: String, page: Int , complition: @escaping (TopHeadlines?, APIError?) -> Void){
        
        dataManager.remote.getHeadlines(countryCode: countryCode, page: page) { (result, error) in
            complition(result,error)
        }
        
    }
}

extension HeadlinesVM {
    
    func filterHeadlines(withText text: String){
        
            if !text.isEmpty{
                self.filteredArticles = articles.filter({ (article) -> Bool in
                    let name = article.title ?? ""
                    let author = article.author ?? ""
                    let description = article.descriptionValue ?? ""
                    return (name.contains(text) || author.contains(text) || description.contains(text))
                })
            }else{
                self.filteredArticles = self.articles
            }
            self.view.reloadData()
        
    }
    
    func cancelFiltering(){
        self.filteredArticles = self.articles
        self.view.reloadData()
    }
    
}

extension HeadlinesVM {
    
    func numberOfItems() -> Int{
        return isDumyData ? 10 : filteredArticles.count
    }
    
    func item(atIndex index: Int) -> Article?{
        guard index >= 0 && index < filteredArticles.count else {
            return nil
        }
        return filteredArticles[index]
    }
    
}

extension HeadlinesVM {
    
    func reachabilityLisiter(){
//        reachability.whenReachable = { reachability in
//            self.view.showMsg(msg: "Connection Back")
//            guard self.isFirstLoad else {
//                return
//            }
//            self.getFirstHeadLines()
//        }
//
//        reachability.whenUnreachable = { _ in
//            self.view.showMsg(msg: "No Connection")
//        }
        
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi, .cellular:
            self.view.showMsg(msg: "Connection Back")
            guard self.isFirstLoad else {
                return
            }
            self.getFirstHeadLines()
        case .none:
            self.view.showMsg(msg: "No Connection")
        }
    }
    
}


