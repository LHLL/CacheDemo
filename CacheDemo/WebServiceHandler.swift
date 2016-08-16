//
//  WebServiceHandler.swift
//  CacheDemo
//
//  Created by Xu, Jay on 7/26/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class WebServiceHandler: NSObject, NSURLSessionDownloadDelegate {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var cell:ResultTableViewCell?
    var resumeData:NSData?
    var downloadManager:NSURLSessionDownloadTask?
    private var backgroundHandler:(()->Void) = {}
    
    func searchHandler(find:String, completion:((result:[SearchResult]?, error:String?)->Void)){
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let url = NSURL(string: "https://itunes.apple.com/search?media=music&entity=song&term=\(find)")
        let request = NSURLRequest(URL: url!)
        let searchManager:NSURLSessionDataTask?
        searchManager = session.dataTaskWithRequest(request) { (result, response, error) in
            guard error == nil else {
                completion(result: nil, error: error?.localizedDescription)
                return
            }
            
            guard result != nil else {
                completion(result: nil, error: "No response from Server")
                return
            }
            
            let jsonDict = try! NSJSONSerialization.JSONObjectWithData(result!, options: .AllowFragments)
            let parseResult = DataParser().parseSearchRequestData(jsonDict as! [String : AnyObject])
            guard parseResult.result != nil else {
                completion(result: nil, error: parseResult.error)
                return
            }
            do {
                try StoreManager().save(parseResult.result!, name: "result") { (status) in
                    if status {
                        print("save success")
                    }else {
                        completion(result:parseResult.result, error: "Unpredicted error happened, cache failed.")
                    }
                }
            }catch let error {
                completion(result:parseResult.result, error: "\(error)")
            }
            completion(result:parseResult.result, error: nil)
        }
        searchManager!.resume()
    }
    
    func downloadHandler(target:String,sender:ResultTableViewCell){
        cell = sender
        let identifer = randomStringFactory()
        registerActiveDownloding(identifer, completion: backgroundHandler)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifer),
                                   delegate: self,
                                   delegateQueue: nil)
        let url = NSURL(string: target)!
        let request = NSURLRequest(URL: url)
        downloadManager = session.downloadTaskWithRequest(request)
        downloadManager!.resume()
    }
    
    func resumeDownloadProcess(){
        let identifer = randomStringFactory()
        registerActiveDownloding(identifer, completion: backgroundHandler)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifer),
                                   delegate: self,
                                   delegateQueue: nil)
        downloadManager = session.downloadTaskWithResumeData(resumeData!)
        downloadManager!.resume()
    }
    
    func randomStringFactory()->String{
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        for _ in (0..<8) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        return randomString
    }
    
    func registerActiveDownloding(identifer:String, completion:(()->Void)){
        
    }
    
    //MARK:NSURLSessionDownloadDelegate
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didFinishDownloadingToURL location: NSURL) {
        let songData = NSData(contentsOfURL: location)
        appDelegate.result[cell!.cellIndex].music = songData!
        do {
            try StoreManager().save(appDelegate.result, name: "result") { (status) in
                if status {
                    print("update download result success")
                }else {
                    print("update download result fail")
                }
            }
        }catch let error {
            print(error)
        }
    }
    
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                                 totalBytesWritten: Int64,
                                 totalBytesExpectedToWrite: Int64) {
        let percentage = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        let total = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: .Binary)
        self.cell?.downloadInfo = (percentage,total)
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        let notification = UILocalNotification()
        appDelegate.result[cell!.cellIndex].isCached = true
        do{
            try StoreManager().save(appDelegate.result, name: "result", completion: { (status) in
                if status {
                    notification.alertBody = "Song is cached"
                    notification.alertAction = "open"
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }else {
                    notification.alertBody = "Download is finished, cache failed"
                    notification.alertAction = "open"
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }
            })
        }catch let error {
            print(error)
        }
        dispatch_async(dispatch_get_main_queue()) { 
            self.appDelegate.backgroundCompletion
        }
    }
}
