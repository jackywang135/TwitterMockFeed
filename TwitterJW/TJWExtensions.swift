//
//  TJWExtensions.swift
//  TwitterJW
//
//  Created by Jacky Wang on 7/9/16.
//  Copyright © 2016 Jacky Wang. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    static var minute: TimeInterval {
        get {
            return 60.0
        }
    }
    
    static var hour: TimeInterval {
        get {
            return minute * 60.0
        }
    }
    static var day: TimeInterval {
        get {
            return hour * 24
        }
    }
}

extension Date {
    
    func getTimeSinceString(date:Date) -> String {
        let secondsSince: TimeInterval = self.timeIntervalSince(date)
        switch secondsSince {
        case let s where s < TimeInterval.minute:
            
            return "\(Int(secondsSince))s"
            
        case let s where s > TimeInterval.minute && s < TimeInterval.hour:
            
            let minutesSince = Int(s/TimeInterval.minute)
            return "\(minutesSince)m"
            
        case let s where s > TimeInterval.hour && s < TimeInterval.day:
            
            let hoursSince = Int(s/TimeInterval.hour)
            return "\(hoursSince)h"
            
        case let s where s > TimeInterval.day:
            
            let daysSince = Int(s/TimeInterval.day)
            return "\(daysSince)d"
            
        default:
            return ""
        }
    }
}
