//
//  ViewController.swift
//  CacheDemo
//
//  Created by Xu, Jay on 7/26/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ErrorDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchTableView.registerNib(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        searchTableView.estimatedRowHeight = 150
        searchTableView.rowHeight = UITableViewAutomaticDimension
        if appDelegate.result.count > 0 {
            searchTableView.hidden = false
        }
    }
    
    //MARK:UITableViewDataSource and UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.result.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ResultTableViewCell
        cell.cellIndex = indexPath.row
        cell.muteAll = {self.stopPlayingMusic()}
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    //MAKR:UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        WebServiceHandler().searchHandler(searchBar.text!) { (result, error) in
            guard result != nil else {
                self.alertCenter(error!)
                return
            }
            self.appDelegate.result = result!
            dispatch_async(dispatch_get_main_queue(), { 
                self.searchTableView.reloadData()
                if error != nil {
                    self.alertCenter(error!)
                }
            })
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        guard appDelegate.cache == NSCache() else {return}
        guard appDelegate.result == [SearchResult]() else {return}
        appDelegate.cache = NSCache()
        appDelegate.result = [SearchResult]()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Utility methods
    func alertCenter(error:String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        dispatch_async(dispatch_get_main_queue()) { 
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func stopPlayingMusic(){
        for index in 0..<appDelegate.result.count {
            if appDelegate.result[index].isPlaying {
                appDelegate.result[index].isPlaying = false
                dispatch_async(dispatch_get_main_queue(), { 
                    let cell = self.searchTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! ResultTableViewCell
                    cell.switchButton.setTitle("Play", forState: .Normal)
                })
            }
        }
    }
}

