//
//  TeamModel.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 4/4/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import Foundation
import ObjectMapper

struct TeamModel: ImmutableMappable {
  let name: String
  let score: Int

  init(name: String, score: Int) {
    self.name = name
    self.score = score
  }

  init(map: Map) throws {
    name = try map.value("name")
    score = try map.value("score")
  }

  func mapping(map: Map) {
    name >>> map["name"]
    score >>> map["score"]
  }

  var teamImage: UIImage {
    let name = self.name.lowercased()

    if name.contains("berkshire") {
      return #imageLiteral(resourceName: "Berkshire_School")
    } else if name.contains("hotchkiss") {
      return #imageLiteral(resourceName: "Hotchkiss_School")
    } else if name.contains("salisbury") {
      return #imageLiteral(resourceName: "Salisbury_School")
    } else if name.contains("taft") {
      return #imageLiteral(resourceName: "Taft_School")
    } else {
      return #imageLiteral(resourceName: "Generic_School")
    }
  }
}
