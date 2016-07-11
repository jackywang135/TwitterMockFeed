//
//  TJWAPI.swift
//  TwitterJW
//
//  Created by Jacky Wang on 7/7/16.
//  Copyright © 2016 Jacky Wang. All rights reserved.
//

import Foundation
import Social
import Accounts

class TJWAPI {
    
    class var sharedAPI: TJWAPI {
        struct singleton {
            static let instance = TJWAPI()
        }
        return singleton.instance
    }
    
    private let accountStore = ACAccountStore()
    private var account: ACAccount?
    
    private var sinceID: Int?
    private var maxID: Int?
    private let defaultFetchPostsCount = 20
    private var lastFetchTime: Date?
    
    func authenticate(callback:(success:Bool)->()) {
 
        let type = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccounts(with: type, options: nil) { success, error in
            guard success && error == nil else {
                callback(success: false)
                // ask user to login
                return
            }
            if let account = self.accountStore.accounts.first as? ACAccount {
                self.account = account
                self.accountStore.saveAccount(account) { success, error in
                    callback(success: true)
                }

            } else {
                // No account found
                callback(success: false)
            }
            
        }
    }
    
    func refreshTimeLine(callback:([[String:AnyObject]]?)->()) {
        
        getTimeLine(count: defaultFetchPostsCount,
                    sinceID: sinceID,
                    maxID: nil) { posts in
                        
                        guard let posts = posts,
                        first = posts.first,
                        last = posts.last else {
                            callback(nil)
                            return
                        }
                        
                        if let id = first["id"] as? Int {
                            self.sinceID = id
                        }
                        if let id = last["id"] as? Int {
                            self.maxID = id
                        }
                        callback(posts)
        }
    }
    
    func scrollTimeLine(callback:([[String:AnyObject]]?)->()) {
        
        getTimeLine(count: defaultFetchPostsCount,
                    sinceID: nil,
                    maxID: maxID) { posts in
                        
                        guard let posts = posts,
                            post = posts.last else {
                                callback(nil)
                                return
                        }
                        
                        if let id = post["id"] as? Int {
                            self.maxID = id
                        }
                        callback(posts)
        }

    }
    
    private func getTimeLine(count: Int?, sinceID: Int?, maxID: Int?, callback:([[String:AnyObject]]?)->()) {
        
        if let lastFetchTime = lastFetchTime where Date().timeIntervalSince(lastFetchTime) < 1.0 {
            return
        } else {
            lastFetchTime = Date()
        }
        
        NSLog("Making Request")
        
        let url = URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        var param = [String:AnyObject]()
        if let count = count {
            param["count"] = "\(count)"
        }
        if let maxID = maxID {
            param["max_id"] = "\(maxID-1)"
        }
        if let sinceID = sinceID {
            param["since_id"] = "\(sinceID)"
        }
        
        let request = SLRequest(forServiceType:SLServiceTypeTwitter,
                                requestMethod: .GET,
                                url: url,
                                parameters: param)
        
        request?.account = self.account
        request?.perform() { data, response, error in
            guard let d = data where error == nil else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:AnyObject]]{
                if let jsonArray = json {
                    callback(jsonArray)
                    return
                }
            }
            callback(nil)
            return
            
        
        }
        
    }
    
}
