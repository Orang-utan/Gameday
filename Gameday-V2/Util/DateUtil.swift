//
//  DateUtil.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import Foundation

func UTCToLocal(date:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd H:mm:ss"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone.ReferenceType.system
    dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
    
    return dateFormatter.string(from: dt!)
}

let monthArr: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
let weekArr: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

func strToDate(date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    guard let date = dateFormatter.date(from: date) else {
        fatalError("ERROR: Date conversion failed due to mismatched format.")
    }
    
    return (date)
}

func formatDateStr(date: String) -> String {
    let dateArr = date.components(separatedBy: "-")
    let month = monthArr[Int(dateArr[1])! - 1]
    let day = Int(dateArr[2])!
    
    let formattedDate = "\(month) \(day)"
    
    return (formattedDate)
}

func strToWeekOfDay(date: String) -> String {
    return weekArr[Calendar.current.component(.weekday, from: strToDate(date: date)) - 1]
}
