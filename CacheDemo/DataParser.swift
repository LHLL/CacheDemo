//
//  DataParser.swift
//  CacheDemo
//
//  Created by Xu, Jay on 7/26/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class DataParser: NSObject {
    
    func parseSearchRequestData(rawData:[String:AnyObject])-> (result:[SearchResult]?,error:String?){
        var resultArr = [SearchResult]()
        guard rawData["results"] is [[String:AnyObject]] else {return (nil,"API Response is Not Right.")}
        let dataArr = rawData["results"] as! [[String:AnyObject]]
        guard dataArr.count > 0 else{return (nil, "No related result found.")}
        for data in dataArr {
            let result = SearchResult()
            result.artistName = data["artistName"] as? String
            result.songName = data["trackName"] as? String
            result.thumbNailPath = data["artworkUrl100"] as? String
            if data["trackPrice"] == nil {
                result.price = ""
            }else {
                result.price = "$\(data["trackPrice"]!)"
            }
            result.downloadPath = data["previewUrl"] as? String
            resultArr.append(result)
        }
        return (resultArr, nil)
    }
}
