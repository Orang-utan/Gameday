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
  var likesCount: Int
  var likeUsersId: [String: Bool]
  var fansCount: Int
  var fanUsersId: [String: Bool]

  var author: UserModel?

  init(map: Map) throws {
    id = try map.value("id")
    authorId = try map.value("author_id")
    createAt = try map.value("create_at")
    updateAt = try map.value("update_at")
    startDate = try map.value("start_date")
    endDate = try map.value("end_date")
    awayTeam = try map.value("away_team")
    homeTeam = try map.value("home_team")
    level = try map.value("level")
    sportType = try map.value("sport_type")
    place = try map.value("place")
    likesCount = (try? map.value("likes_count")) ?? 0
    likeUsersId = (try? map.value("like_users_id")) ?? [:]
    fansCount = (try? map.value("fans_count")) ?? 0
    fanUsersId = (try? map.value("fan_users_id")) ?? [:]
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

  var isLiked: Bool {
    return likeUsersId.contains(where: { (key, _) -> Bool in
      return key == CURRENT_USER_ID
    })
  }

  var isFan: Bool {
    return fanUsersId.contains(where: { (key, _) -> Bool in
      return key == CURRENT_USER_ID
    })
  }
}
