//
//  HeadlinesVC.swift
//  news
//
//  Created by mac2 on 9/4/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit
import Windless
import DGElasticPullToRefresh
import CDAlertView

class HeadlinesVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var listGridButton: UIBarButtonItem!
    
    private enum HeadlinesListType: Int {
        case list = 0,
        grid
    }
    
    private var currentViewType: HeadlinesListType = .list {
        didSet{
            collectionView.reloadData()
        }
    }
    
    var headlinesVM: HeadlinesVM!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var searchBar:UISearchBar = {
        
        let sBar =  UISearchBar(frame: CGRect.zero)
        sBar.sizeToFit()
        sBar.delegate = self
        sBar.placeholder = "Search in Headlines"
        sBar.showsCancelButton = true
        sBar.setValue("Cancel", forKey:"cancelButtonText")
        return sBar
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchController()
        self.headlinesVM = HeadlinesVM(view: self)
        
        self.registerCellsToCollectionView()
        self.setupWindless()
        
        self.headlinesVM.getFirstHeadLines()
        self.setupRefreshControl()
        
    }
    
    @IBAction func listGridButtonTapped(_ sender: Any) {
        if currentViewType == .list {
            currentViewType = .grid
            self.listGridButton.image = UIImage(named: "listIcon")
        }else{
            currentViewType = .list
            self.listGridButton.image = UIImage(named: "gridIcon")
        }
    }
    
    func registerCellsToCollectionView() {
        let listNib = UINib.init(nibName: ListHeadlineCell.getCellIdentifier(), bundle: nil)
        self.collectionView.register(listNib, forCellWithReuseIdentifier: ListHeadlineCell.getCellIdentifier())
        
        let gridNib = UINib.init(nibName: GridHeadlineCell.getCellIdentifier(), bundle: nil)
        self.collectionView.register(gridNib, forCellWithReuseIdentifier: GridHeadlineCell.getCellIdentifier())
    }
    
}


//MARK: Windless
extension HeadlinesVC {
    
    func setupWindless(){
        self.collectionView.windless
            .apply {
                $0.beginTime = 0
                $0.pauseDuration = 1
                $0.duration = 3
                $0.animationLayerOpacity = 0.8
        }
    }
    
    func startWindless(){
        self.collectionView.windless.start()
    }
    
    func stopWindless(){
        self.collectionView.windless.end()
    }
    
}


//MARK: HeadLinesView delegate
extension HeadlinesVC: HeadLinesView{
    
    func startWindlessLoader(){
        startWindless()
    }
    
    func endWindlessLoader(){
        stopWindless()
    }
    
    func endRefreshLoader(){
        self.collectionView.dg_stopLoading()
    }
    
    func reloadData(){
        self.collectionView.reloadData()
    }
    
    func showMsg(msg: String?){
        if let msg = msg{
            self.showStatusBarMessage(body: msg)
        }
    }
}

//MARK: Search bar
extension HeadlinesVC {
    
    func setupSearchController() {
        // Setup the Search Controller
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.setValue("Cancel", forKey:"_cancelButtonText")
        searchController.searchBar.setImage(UIImage(named: "ic_search"), for: .search, state: .normal)

        if let textField = searchController.searchBar.subviews.first?.subviews.compactMap({ $0 as? UITextField }).first {
            textField.layer.cornerRadius = 18
            textField.layer.masksToBounds = true
        }
        
        self.navigationItem.titleView = searchController.searchBar

    }
}

//MARK: Refresh control
extension HeadlinesVC {
    
    func setupRefreshControl(){
        
            // Initialize tableView
            let loadingView = DGElasticPullToRefreshLoadingViewCircle()
            loadingView.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            collectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                // Add your logic here
                
                self?.refreshData()
              
                }, loadingView: loadingView)
            collectionView.dg_setPullToRefreshFillColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
            collectionView.dg_setPullToRefreshBackgroundColor(collectionView.backgroundColor!)
    
    }
    
    func refreshData() {
        self.headlinesVM.refreshHeadlines()
    }
}

//MARK: UISearchBarDelegate
extension HeadlinesVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.headlinesVM.cancelFiltering()
        print("canceled")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.headlinesVM.filterHeadlines(withText: searchText)
        print(searchText)
    }
    
}

//MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension HeadlinesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.headlinesVM.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier: String = GridHeadlineCell.getCellIdentifier()  //currentViewType == .grid ?  GridHeadlineCell.getCellIdentifier() : ListHeadlineCell.getCellIdentifier()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HeadlineCell
        
        if let item = headlinesVM.item(atIndex: indexPath.row) {
            cell.configure(data: item)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let itemsCount = headlinesVM?.numberOfItems(), (indexPath.row) == itemsCount - 1 {
            print("last item")
            self.headlinesVM?.loadMoreHeadLines()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let desc = headlinesVM.item(atIndex: indexPath.row)?.descriptionValue , desc != "" {
            
            let authorName = headlinesVM.item(atIndex: indexPath.row)?.author ?? ""
            let alert = CDAlertView(title: authorName, message: desc, type: .alarm)
            
            alert.messageFont = UIFont(name: "DroidArabicKufi", size: 16)!
            alert.titleFont = UIFont(name: "DroidArabicKufi", size: 14)!
            alert.messageTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            alert.titleTextColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            let doneAction = CDAlertViewAction(title: "DONE")
            alert.add(action: doneAction)
            
            alert.show()
        }else {
            self.showMsg(msg: "No Description found for this headline")
        }

    }
    
}

extension HeadlinesVC: UICollectionViewDelegateFlowLayout {
    

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        var cellWidth = collectionView.frame.size.width - 16
        let cellIdentifier: String = GridHeadlineCell.getCellIdentifier()
        
        if currentViewType == .grid{
            cellWidth = cellWidth / 2
//            cellIdentifier = GridHeadlineCell.getCellIdentifier()
        }
        let cell = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)?.first as! HeadlineCell
        
        if let item = headlinesVM.item(atIndex: indexPath.row) {
            cell.configure(data: item)
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
        
        let targetSize = CGSize(width: cellWidth, height: 0)
        
        let size = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return size
    }
}
