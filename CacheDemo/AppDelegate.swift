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
        do {
            try StoreManager().save(result, name: "result") { (status) in
                if status {
                    print("update successes before exit")
                }else {
                    print("update fails before exit")
                }
            }
        }catch let error {
            print(error)
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        //Show right UI when background downloading is finished
        let navi = window?.rootViewController as! UINavigationController
        let vc = navi.viewControllers[0] as! ViewController
        if !vc.searchTableView.hidden {
            vc.searchTableView.reloadData()
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {

    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        backgroundCompletion = completionHandler
    }
    
}

