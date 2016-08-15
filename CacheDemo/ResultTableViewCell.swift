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
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var terminateDownloading: UIButton!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var downloadLabel: UILabel!
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var cellIndex = -1
    var webServiceHandler = WebServiceHandler()
    var downloadInfo:(percentage:Float, total:String) = (0,"") {
        didSet{
            if downloadInfo.percentage == 1.0 {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.downloadLabel.text = "Done"
                    self.progressBar.progress = self.downloadInfo.percentage
                    self.switchButton.setTitle("Play", forState: .Normal)
                    self.terminateDownloading.setTitle("Delete", forState: .Normal)
                    self.appDelegate.result[self.cellIndex].isCached = true
                })
            }else {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.progressBar.progress = self.downloadInfo.percentage
                    let per = self.downloadInfo.percentage*100
                    self.downloadLabel.text = "\(Double(round(100*per/100)))%/\(self.downloadInfo.total)"
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadLabel.text = ""
        progressBar.progress = 0
        terminateDownloading.setTitle("Cancel", forState: .Normal)
        switchButton.setTitle("Pause", forState: .Normal)
    }
    
    override func prepareForReuse() {
        progressBar.progress = 0
        downloadLabel.text = ""
        downloadView.hidden = true
        progressBar.hidden = true
        downloadLabel.hidden = true
        downloadTheSong.enabled = true
        terminateDownloading.setTitle("Cancel", forState: .Normal)
        switchButton.setTitle("Pause", forState: .Normal)
    }
    
    override func layoutSubviews() {
        songName.text = appDelegate.result[cellIndex].songName
        artistName.text = appDelegate.result[cellIndex].artistName
        price.text = appDelegate.result[cellIndex].price
        if appDelegate.result[self.cellIndex].isCached {
            downloadTheSong.enabled = false
            downloadView.hidden = false
            switchButton.setTitle("Play", forState: .Normal)
            terminateDownloading.setTitle("Delete", forState: .Normal)
        }
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
            let imageData = NSData(contentsOfURL: NSURL(string: self.appDelegate.result[self.cellIndex].thumbNailPath!)!)
            let image = UIImage(data: imageData!)
            self.appDelegate.cache.setObject(image!, forKey: self.cellIndex)
            dispatch_async(dispatch_get_main_queue(), { 
                self.thumbNail.image = image
            })
        }
    }
    
    @IBAction func terminateDoloadingTask(sender: UIButton) {
        if sender.titleLabel?.text == "Delete" {
            if MusicPlayer.player != nil {
                MusicPlayer.stop()
            }
            progressBar.progress = 0
            downloadView.hidden = true
            downloadTheSong.enabled = true
            appDelegate.result[cellIndex].music = NSData()
            progressBar.hidden = true
            downloadLabel.hidden = true
            terminateDownloading.setTitle("Cancel", forState: .Normal)
            switchButton.setTitle("Pause", forState: .Normal)
        }else if sender.titleLabel?.text == "Cancel" {
            webServiceHandler.downloadManager!.cancel()
        }
    }
    
    @IBAction func downloadSwitchTrigger(sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            MusicPlayer.initWithFilePath(appDelegate.result[cellIndex].music)
            MusicPlayer.play()
            sender.setTitle("Stop", forState: .Normal)
            progressBar.hidden = true
            downloadLabel.hidden = true
        }else if sender.titleLabel?.text == "Stop" {
            MusicPlayer.stop()
            sender.setTitle("Play", forState: .Normal)
        }else if sender.titleLabel?.text == "Pause" {
            webServiceHandler.downloadManager!.cancelByProducingResumeData({ (data) in
                if data != nil {
                    self.webServiceHandler.resumeData = data
                }
            })
            sender.setTitle("Resume", forState: .Normal)
        }else if sender.titleLabel?.text == "Resume" {
            webServiceHandler.resumeDownloadProcess()
            sender.setTitle("Pause", forState: .Normal)
        }
    }
    
    @IBAction func startDownloading(sender: UIButton) {
        downloadTheSong.enabled = false
        downloadView.hidden = false
        progressBar.hidden = false
        downloadLabel.hidden = false
        webServiceHandler.downloadHandler(appDelegate.result[cellIndex].downloadPath!,sender:self)
    }
}
