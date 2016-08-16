//
//  StoreManager.swift
//  CacheDemo
//
//  Created by Xu, Jay on 8/12/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class StoreManager: NSObject {
    
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    private let storeQueue = dispatch_queue_create("storeQ", DISPATCH_QUEUE_CONCURRENT)
    let fileManager = NSFileManager.defaultManager()
    func save(object:AnyObject, name:String, completion:(status:Bool)->Void) throws {
        guard fileManager.fileExistsAtPath(path + "/" + name) == false else {
            do{
                try fileManager.removeItemAtPath(path  + "/" + name)
            }catch let error {
                throw error
            }
            dispatch_barrier_async(storeQueue, {
                if NSKeyedArchiver.archiveRootObject(object, toFile: self.path + "/" + name) {
                    completion(status: true)
                }else {
                    completion(status: false)
                }
            })
            return
        }
        
        dispatch_barrier_async(storeQueue, {
            if NSKeyedArchiver.archiveRootObject(object, toFile: self.path + "/" + name) {
                completion(status: true)
            }else {
                completion(status: false)
            }
        })
    }
    
    func withdraw(name:String,completionHandler:(status:Bool, object:AnyObject?)->Void) throws {
        guard fileManager.fileExistsAtPath(path  + "/" + name) else {
            throw PersistentError.NoSuchFileFound
        }
        dispatch_barrier_async(storeQueue) { 
            let result = NSKeyedUnarchiver.unarchiveObjectWithFile(self.path  + "/" + name)
            if result == nil {
                completionHandler(status: false, object: nil)
            }else {
                completionHandler(status: true, object: result)
            }
        }
    }
}

enum PersistentError:ErrorType {
    case DuplicateName
    case NoSuchFileFound
    case SystemError
}
