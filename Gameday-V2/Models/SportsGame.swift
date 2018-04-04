//
//  SportsGame.swift
//  Gameday-V2
//
//  Created by Daniel on 3/31/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import Foundation
import UIKit

class SportsGame {
    
    var id: String!
    var author: UserProfile!
    
    var sportsType: String! //lacrosse, baseball, etc.
    var sportsLevel: String! //Boys varsity, Girls JV, etc.
    
    var homeTeam: String! //berkshire
    var awayTeam: String! //taft
    
    var homeScore = 0
    var awayScore = 0
    
    var like: Int = 0
    var rsvp: [UserProfile] = []
    
    var time: String! //2018-03-11 14:25:13
    var date: String! //2018-03-11
    
    var location: String!
    
    var timestamp: Double
    
    init(id: String, author: UserProfile, sportsType: String, sportsLevel: String, homeTeam: String, awayTeam: String, time: String, date: String, location: String, timestamp: Double) {
        self.id = id
        self.author = author
        self.sportsType = sportsType
        self.sportsLevel = sportsLevel
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.time = time
        self.date = date
        self.location = location
        self.timestamp = timestamp
    }
    
    func getGameTitle() -> String {
        return "\(self.sportsLevel!) \(self.sportsType!)"
    }
    
    func getTime() -> String {
        let local = UTCToLocal(date: time)
        let dateArr = "\(local)".components(separatedBy: " ")
        return dateArr[1]
    }
    
    func getDate() -> String {
        let local = UTCToLocal(date: time)
        let dateArr = "\(local)".components(separatedBy: " ")
        return formatDateStr(date: dateArr[0])
    }
    
    func getTeamImage(team: String) -> UIImage {
        let team_formatted = team.lowercased()
        
        if team_formatted.contains("berkshire") {
            return #imageLiteral(resourceName: "Berkshire_School")
        } else if team_formatted.contains("hotchkiss") {
            return #imageLiteral(resourceName: "Hotchkiss_School")
        } else if team_formatted.contains("salisbury") {
            return #imageLiteral(resourceName: "Salisbury_School")
        } else if team_formatted.contains("taft") {
            return #imageLiteral(resourceName: "Taft_School")
        } else {
            return #imageLiteral(resourceName: "Generic_School")
        }
    }
    
}
