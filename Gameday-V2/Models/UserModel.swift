//
//  UserModel.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 2/13/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import ObjectMapper

struct UserModel: ImmutableMappable {
  let id: String
  let displayName: String?
  let photoURL: String?
  let creationDate: Date?
  let email: String

  init(map: Map) throws {
    id = try map.value("id")
    displayName = try? map.value("display_name")
    photoURL = try? map.value("photo_url")
    creationDate = (try? map.value("creation_date")) ?? (try? map.value("creation_date", using: DateTransform()))
    email = try map.value("email")
  }

  func mapping(map: Map) {
    id >>> map["id"]
    displayName >>> map["display_name"]
    photoURL >>> map["photo_url"]
    email >>> map["email"]
    creationDate >>> (map["creation_date"], DateTransform())
  }
}
