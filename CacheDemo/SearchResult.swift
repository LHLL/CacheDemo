//
//  SearchResult.swift
//  CacheDemo
//
//  Created by Xu, Jay on 7/26/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class SearchResult: NSObject {
    var songName:String?
    var artistName:String?
    var thumbNailPath:String?
    var price:String?
    var downloadPath:String?
    var isDownloading = false
    var isCached = false
    var music = NSData()
    
    required convenience init(coder aDecoder:NSCoder) {
        self.init()
        songName = aDecoder.decodeObjectForKey("name") as? String
        artistName = aDecoder.decodeObjectForKey("artist") as? String
        thumbNailPath = aDecoder.decodeObjectForKey("path") as? String
        price = aDecoder.decodeObjectForKey("price") as? String
        downloadPath = aDecoder.decodeObjectForKey("download") as? String
        isDownloading = aDecoder.decodeObjectForKey("isD") as! Bool
        isCached = aDecoder.decodeObjectForKey("isC") as! Bool
        music = aDecoder.decodeObjectForKey("music") as! NSData
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(songName, forKey: "name")
        aCoder.encodeObject(artistName, forKey: "artist")
        aCoder.encodeObject(thumbNailPath, forKey: "path")
        aCoder.encodeObject(price, forKey: "price")
        aCoder.encodeObject(downloadPath, forKey: "download")
        aCoder.encodeObject(isDownloading, forKey: "isD")
        aCoder.encodeObject(isCached, forKey: "isC")
        aCoder.encodeObject(music, forKey: "music")
    }
}
