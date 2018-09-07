//
//  HeadlineCell.swift
//  news
//
//  Created by mac2 on 9/6/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit
import SDWebImage

protocol ConfigurableCell {
    associatedtype DataType
    func configure(data: DataType)
    
    static var reuseIdentifier: String { get }
    static func getCellIdentifier() -> String
}

extension ConfigurableCell {
    static var reuseIdentifier: String { return String(describing: Self.self) }
    static func getCellIdentifier() -> String {
        return reuseIdentifier
    }
}

class HeadlineCell: UICollectionViewCell, ConfigurableCell {
    
    @IBOutlet weak var headlineImage: UIImageView!
    @IBOutlet weak var headlineTitle: UILabel!
    @IBOutlet weak var headlineAuthor: UILabel!
    @IBOutlet weak var headlineDescription: UILabel!
        
    class func getCellIdentifier() -> String {
        return reuseIdentifier
    }

    func configure(data: Article) {
        self.headlineTitle.text = data.title
        self.headlineAuthor.text = data.author
        self.headlineDescription.text = data.descriptionValue
        self.setHeadlineImage(imageUrl: data.urlToImage)
    }
    
    private func setHeadlineImage(imageUrl: String?) {
        
        var url: URL?
        if let photo = imageUrl{
            url = URL(string: photo)
        }
        self.headlineImage.sd_setImage(with: url)
        
    }
    
    func cellHeight() -> CGFloat {
        return self.headlineTitle.intrinsicContentSize.height + self.headlineAuthor.intrinsicContentSize.height + self.headlineDescription.intrinsicContentSize.height
    }
   
}

class ListHeadlineCell: HeadlineCell {
    
    let defaultCellHeight: CGFloat = 142.0
    
    override class func getCellIdentifier() -> String {
        return "List\(super.getCellIdentifier())"
    }
    
    override func cellHeight() -> CGFloat {
        let spacesHeight: CGFloat = 40
        let contentCellHeight = super.cellHeight() + spacesHeight
        return contentCellHeight < defaultCellHeight ? defaultCellHeight : contentCellHeight
    }
    
}

class GridHeadlineCell: HeadlineCell {
    
    let defaultCellHeight: CGFloat = 215.0
    
    override class func getCellIdentifier() -> String {
        return "Grid\(super.getCellIdentifier())"
    }
    
    override func cellHeight() -> CGFloat {
        let imageHeight: CGFloat = 100
        let spacesHeight: CGFloat = 35
        let contentCellHeight = super.cellHeight() + imageHeight + spacesHeight
        return contentCellHeight < defaultCellHeight ? defaultCellHeight : contentCellHeight
    }
    
}
