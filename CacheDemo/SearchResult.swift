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
}
