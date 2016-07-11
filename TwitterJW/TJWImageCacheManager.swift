//
//  TJWImageCacheManager.swift
//  TwitterJW
//
//  Created by Jacky Wang on 7/8/16.
//  Copyright © 2016 Jacky Wang. All rights reserved.
//

import Foundation

// This class manages saving and getting images from the caches domain

class TJWImageCacheManager {
    
    func saveImage(url: String, imageData: Data) {
        let _ = try? imageData.write(to: URL(fileURLWithPath: convertURLToPath(urlString: url)))
    }
    
    func getImage(url: String) -> Data? {
        return try? Data(contentsOf:URL(fileURLWithPath: convertURLToPath(urlString: url)))
    }
    
    private func convertURLToPath(urlString:String) -> String {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        
        return dirPath + "/" + urlString.replacingOccurrences(of: "/", with: "")
    }
}
