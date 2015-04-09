 //
//  FSSettingsViewController.swift
//  Rococo's Image2PDF
//
//  Created by zhefu wang on 10/7/14.
//  Copyright (c) 2014 Nonomori. All rights reserved.
//

import UIKit

class FSSettingsViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: FSPagingScrollView!
    @IBOutlet weak var descriptionLabel: UILabel!
    let pageArray: [String] = ["LETTER","A3","A4","A5","B4","B5"]
    var pageIndex: Int = 0 {
        didSet{
            if let pageSizeDic:[String:AnyObject] = self.allPageDictionary?["PAGESIZE_\(self.pageArray[pageIndex])"]{
                let width = pageSizeDic["width_inch"]! as! Float
                let height = pageSizeDic["height_inch"]! as! Float
                self.descriptionLabel.text = String(format: "%.2fx%.2f inch", width, height)
            }
        }
    }
    
    var allPageDictionary: Dictionary<String, Dictionary<String, AnyObject>>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let jsonData: NSData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("pageSize", ofType: "json")!, options: nil, error: nil)!
        
        self.allPageDictionary = NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers, error: nil) as? [String:[String:AnyObject]]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for i in 0..<self.pageArray.count {
            var pageDic: Dictionary<String, AnyObject>? = self.allPageDictionary!["PAGESIZE_\(self.pageArray[i])"]
            var frame:CGRect = CGRectZero
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(i) + 20
            frame.origin.y = 12
            frame.size = CGSize(width: 160, height: 200)
            var subview = UIImageView(frame: frame)
            
            if let imageName = pageDic?["image"] as AnyObject? as? String{
                subview.image = UIImage(named: imageName)
            }
            self.scrollView.addSubview(subview)
            self.scrollView.contentSize = CGSize(width: CGFloat(200 * self.pageArray.count), height: self.scrollView.frame.size.height)
            self.scrollView.responseInsets = UIEdgeInsets(top: 0, left: CGRectGetMidX(self.view.bounds) - CGRectGetMidX(self.scrollView.bounds), bottom: 0, right: CGRectGetMidX(self.view.bounds) - CGRectGetMidX(self.scrollView.bounds))
            
            if let pageSizeDict = NSUserDefaults.standardUserDefaults().objectForKey("pageSize") as? Dictionary<String, AnyObject>{
                if let name = pageSizeDict["name"] as AnyObject? as? String{
                    if let index = find(self.pageArray, name){
                        let rect = CGRect(x: CGFloat(200 * index), y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height)
                        self.scrollView.scrollRectToVisible(rect, animated: true)
                    }
                }
            }
        }
    }
    
    
    @IBAction func cancelButtonTouched(sender: UIButton) {
        if let pageSizeDic: Dictionary<String,AnyObject> = self.allPageDictionary?["PAGESIZE_\(self.pageArray[self.pageIndex])"]{
            println(pageSizeDic)
            NSUserDefaults.standardUserDefaults().setObject(pageSizeDic, forKey: "pageSize")
            NSUserDefaults.standardUserDefaults().synchronize()
            if let navCV: FSNavigationController = self.navigationController as? FSNavigationController{
                navCV.popViewControllerWithSlideAnimation()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func isAllowedSwipeBack() -> Bool{
        return false
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = self.scrollView.frame.size.width
        var tmp = Int(floor((self.scrollView.contentOffset.x - pageWidth * 0.5)/pageWidth)) + 1
        if tmp < 0 {
            tmp = 0
        }
        if tmp >= self.pageArray.count {
            tmp = self.pageArray.count - 1
        }
        self.pageIndex = tmp
    }

}
