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
    private var isDownloading = false
    private var progress = 0.0
    var resumeData:NSData?
    
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
            completion(result:parseResult.result, error: nil)
        }
        searchManager!.resume()
    }
    
    func downloadHandler(target:String){
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let url = NSURL(string: target)!
        let request = NSURLRequest(URL: url)
        let downloadManager:NSURLSessionDownloadTask?
        downloadManager = session.downloadTaskWithRequest(request, completionHandler: { (path, response, error) in
            let songData = NSData(contentsOfURL: path!)
            self.appDelegate.songFile = songData!
        })
        downloadManager?.resume()
        
//        downloadManager = session.downloadTaskWithRequest(request)
//        downloadManager!.resume()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("finished")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print(bytesWritten/totalBytesWritten)
    }
    
}
