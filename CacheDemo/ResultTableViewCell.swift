//
//  ResultTableViewCell.swift
//  CacheDemo
//
//  Created by Xu, Jay on 7/26/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbNail: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var downloadTheSong: UIButton!
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var cellIndex = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        songName.text = appDelegate.result[cellIndex].songName
        artistName.text = appDelegate.result[cellIndex].artistName
        price.text = appDelegate.result[cellIndex].price
        if appDelegate.cache.objectForKey(cellIndex) != nil {
            thumbNail.image = appDelegate.cache.objectForKey(cellIndex) as? UIImage
        }else {
            imageLoader()
        }
        imageLoader()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func imageLoader(){
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            let imageData = NSData(contentsOfURL: NSURL(string: self.appDelegate.result[self.cellIndex].thumbNailPath)!)
            let image = UIImage(data: imageData!)
            self.appDelegate.cache.setObject(image!, forKey: self.cellIndex)
            dispatch_async(dispatch_get_main_queue(), { 
                self.thumbNail.image = image
            })
        }
    }
    
    @IBAction func startDownloading(sender: UIButton) {
        WebServiceHandler().downloadHandler(appDelegate.result[cellIndex].downloadPath)
    }
    

}
