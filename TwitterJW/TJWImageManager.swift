//
//  TJWImageCacheManager.swift
//  TwitterJW
//
//  Created by Jacky Wang on 7/8/16.
//  Copyright © 2016 Jacky Wang. All rights reserved.
//

import Foundation

// This class handles fetching images from Cache or Network 

class TJWImageManager {
    
    class var sharedManager: TJWImageManager {
        struct singleton {
            static let instance = TJWImageManager()
        }
        return singleton.instance
    }
    
    let cacheManager = TJWImageCacheManager()
    
    func requestImage(urlString:String, callback: (Data?) -> ()) {
        
        // Check if image is in cache
        
        if let imageData = cacheManager.getImage(url: urlString) {
            callback(imageData)
        }
        
        // If not in cache, Download image
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data where error == nil else {
                callback(nil)
                return }
            
            // Callback on Main Queue
            
            DispatchQueue.main.async() {
                callback(data)
                
                // Save to Cache
                
                self.cacheManager.saveImage(url: urlString, imageData: data)
            }
            return
        }
        task.resume()
    }
}
