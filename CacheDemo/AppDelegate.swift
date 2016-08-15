//
//  AppDelegate.swift
//  CacheDemo
//
//  Created by Xu, Jay on 7/26/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var result = [SearchResult]()
    var cache = NSCache()
    private var appStatus = ""
    var backgroundCompletion:(()->Void)?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        let manager = StoreManager()
        do {
            try manager.withdraw("result", completionHandler: { (success, object) in
                if success {
                    self.result = object as! [SearchResult]
                }
            })
        }catch let error {
            print(error)
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {

        appStatus = "background"
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        saveResultWhenAppWillTerminate()
    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        backgroundCompletion = completionHandler
    }
    
    func saveResultWhenAppWillTerminate(){
        let manager = StoreManager()
        do {
            try manager.save(result, name: "result", completion: { (success) in
                if success {
                    print("success")
                }
            })
        }catch let error {
            print(error)
        }
    }

}

