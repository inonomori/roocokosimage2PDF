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
            guard let pageSizeDict: [String:AnyObject] = allPageDictionary?["PAGESIZE_\(pageArray[pageIndex])"] else {
                return
            }
            guard let width: Float = pageSizeDict["width_inch"] as? Float, height: Float = pageSizeDict["height_inch"] as? Float else {
                return
            }
            descriptionLabel.text = String(format: "%.2fx%.2f inch", width, height)
        }
    }
    
    var allPageDictionary: [String:[String:AnyObject]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let jsonData: NSData = try! NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("pageSize", ofType: "json")!, options: [])
        
        allPageDictionary = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers)) as? [String:[String:AnyObject]]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for i in 0..<pageArray.count {
            var pageDic: Dictionary<String, AnyObject>? = allPageDictionary!["PAGESIZE_\(pageArray[i])"]
            var frame:CGRect = CGRectZero
            frame.origin.x = scrollView.frame.size.width * CGFloat(i) + 20
            frame.origin.y = 12
            frame.size = CGSize(width: 160, height: 200)
            let subview = UIImageView(frame: frame)
            
            if let imageName = pageDic?["image"] as? String{
                subview.image = UIImage(named: imageName)
            }
            scrollView.addSubview(subview)
            scrollView.contentSize = CGSize(width: CGFloat(200 * pageArray.count), height: scrollView.frame.size.height)
            scrollView.responseInsets = UIEdgeInsets(top: 0, left: CGRectGetMidX(view.bounds) - CGRectGetMidX(scrollView.bounds), bottom: 0, right: CGRectGetMidX(view.bounds) - CGRectGetMidX(scrollView.bounds))
            
            if let pageSizeDict = NSUserDefaults.standardUserDefaults().objectForKey("pageSize") as? Dictionary<String, AnyObject>{
                if let name = pageSizeDict["name"] as? String{
                    if let index = pageArray.indexOf(name){
                        let rect = CGRect(x: CGFloat(200 * index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                        scrollView.scrollRectToVisible(rect, animated: true)
                    }
                }
            }
        }
    }
    
    
    @IBAction func cancelButtonTouched(sender: UIButton) {
        guard let pageSizeDict: [String:AnyObject] = allPageDictionary?["PAGESIZE_\(pageArray[pageIndex])"] else {
            return
        }
        NSUserDefaults.standardUserDefaults().setObject(pageSizeDict, forKey: "pageSize")
        NSUserDefaults.standardUserDefaults().synchronize()
        if let navCV: FSNavigationController = navigationController as? FSNavigationController{
            navCV.popViewControllerWithSlideAnimation()
        }
    }
    
    func isAllowedSwipeBack() -> Bool{
        return false
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        var tmp = Int(floor((scrollView.contentOffset.x - pageWidth * 0.5)/pageWidth)) + 1
        if tmp < 0 {
            tmp = 0
        }
        if tmp >= pageArray.count {
            tmp = pageArray.count - 1
        }
        pageIndex = tmp
    }

}
