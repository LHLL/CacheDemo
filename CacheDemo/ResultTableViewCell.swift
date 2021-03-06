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
    var muteAll:(()->Void)?
    weak var delegate:ErrorDelegate?
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
            progressBar.hidden = true
            terminateDownloading.setTitle("Delete", forState: .Normal)
        }
        if appDelegate.cache.objectForKey(cellIndex) != nil {
            thumbNail.image = appDelegate.cache.objectForKey(cellIndex) as? UIImage
        }else if appDelegate.result[cellIndex].thumbnail == nil{
            imageLoader()
        }else {
            thumbNail.image = appDelegate.result[cellIndex].thumbnail
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func imageLoader(){
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            let imageData = NSData(contentsOfURL: NSURL(string: self.appDelegate.result[self.cellIndex].thumbNailPath!)!)
            let image = UIImage(data: imageData!)
            self.appDelegate.result[self.cellIndex].thumbnail = image
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
            downloadLabel.text = ""
            appDelegate.result[cellIndex].music = NSData()
            progressBar.hidden = true
            downloadLabel.hidden = true
            terminateDownloading.setTitle("Cancel", forState: .Normal)
            switchButton.setTitle("Pause", forState: .Normal)
            do {
                try StoreManager().save(appDelegate.result, name: "result") { (status) in
                    if status == false {
                        self.delegate?.shouldShowAlert("Can not delete song on the disk.")
                    }
                }
            }catch let error {
                self.delegate?.shouldShowAlert("\(error)")
            }
        }else if sender.titleLabel?.text == "Cancel" {
            webServiceHandler.downloadManager!.cancel()
            webServiceHandler.resumeData = nil
            progressBar.progress = 0
            progressBar.hidden = true
            downloadLabel.hidden = true
            downloadTheSong.enabled = true
            downloadView.hidden = true
        }
    }
    
    @IBAction func downloadSwitchTrigger(sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            muteAll!()
            appDelegate.result[cellIndex].isPlaying = true
            MusicPlayer.initWithFilePath(appDelegate.result[cellIndex].music)
            MusicPlayer.play()
            sender.setTitle("Stop", forState: .Normal)
            progressBar.hidden = true
            downloadLabel.hidden = true
        }else if sender.titleLabel?.text == "Stop" {
            MusicPlayer.stop()
            appDelegate.result[cellIndex].isPlaying = false
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

protocol ErrorDelegate: class {
    func shouldShowAlert(error:String);
}

extension ErrorDelegate where Self: UIViewController {
    func shouldShowAlert(error:String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        dispatch_async(dispatch_get_main_queue()) { 
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
