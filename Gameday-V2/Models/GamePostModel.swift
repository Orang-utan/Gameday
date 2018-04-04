//
//  GamePostModel.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 4/4/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import Foundation
import ObjectMapper

enum MatchStatus {
  case live
  case final
  case upcomming
}

struct GamePostModel: ImmutableMappable {
  let id: String
  let authorId: String
  let createAt: Date
  let updateAt: Date
  let startDate: Date
  let endDate: Date
  let awayTeam: TeamModel
  let homeTeam: TeamModel
  let level: String
  let sportType: String
  let place: String

  var author: UserModel?

  init(map: Map) throws {
    id = try map.value("id")
    authorId = try map.value("author_id")
    createAt = try map.value("create_at")
    updateAt = try map.value("update_at")
    startDate = try map.value("start_date")
    awayTeam = try map.value("away_team")
    homeTeam = try map.value("home_team")
    level = try map.value("level")
    sportType = try map.value("sport_type")
    place = try map.value("place")

    var temp = startDate.add(4.hours)
    if temp.isTomorrow {
      temp.hour(0)
      temp.minute(0)
    }
    endDate = temp
  }

  var gameTitle: String {
    return "\(self.level) \(self.sportType)"
  }

  var status: MatchStatus {
    if endDate < Date() {
      return .final
    }

    return startDate < Date() ? .live : .upcomming
  }
}
