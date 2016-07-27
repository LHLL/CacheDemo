
//
//  MusicPlayer.swift
//  CacheDemo
//
//  Created by Xu, Jay on 7/27/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayer: NSObject {
    static var player:AVAudioPlayer!
    static func initWithFilePath(data:NSData){
        if player != nil {
            stop()
        }
        player = try! AVAudioPlayer(data:data)
    }
    
    static func play(){
        player.play()
    }
    
    static func stop(){
        player.stop()
    }
    
    static func pause(){
        player.pause()
    }
}
