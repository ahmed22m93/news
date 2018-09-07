//
//  extensions.swift
//  news
//
//  Created by mac2 on 9/3/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit
import SwiftMessages

extension NSLocale {
    
    class var deviceCountryCode: String {
        let code = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        return code ?? "US"
    }
    
}


extension UIStoryboard {
    
    static var Main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
}

extension UIViewController {
    
    func showStatusBarMessage(body:String) {
        let status = MessageView.viewFromNib(layout: .statusLine)
        status.backgroundView.backgroundColor = UIColor(red: 120/255, green: 28/255, blue: 46/255, alpha: 1)
        status.bodyLabel?.textColor = UIColor.white
        status.configureContent(body: body)
        var statusConfig = SwiftMessages.defaultConfig
        statusConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        statusConfig.preferredStatusBarStyle = .lightContent
        SwiftMessages.show(config: statusConfig, view: status)
    }
    
}
