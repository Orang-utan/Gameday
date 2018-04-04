//
//  GamePostModel.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 4/4/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import Foundation
import ObjectMapper

struct GamePostModel: ImmutableMappable {
  let id: String
  let authorId: String
  let createAt: Date
  let updateAt: Date
  let startDate: Date
  let endDate: Date

  init(map: Map) throws {
    id = try map.value("id")
    authorId = try map.value("author_id")
    createAt = try map.value("create_at")
    updateAt = try map.value("update_at")
    startDate = try map.value("start_date", using: DateTransform())
    endDate = try map.value("end_date", using: DateTransform())
  }
}
