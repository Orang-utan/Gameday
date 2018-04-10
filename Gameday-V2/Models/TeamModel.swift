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
    } else if name.contains("miss porters") {
        return #imageLiteral(resourceName: "MissPorters")
    } else if name.contains("northfield mount hermon") {
        return #imageLiteral(resourceName: "NMH")
    } else if name.contains("pomfret") {
        return #imageLiteral(resourceName: "Pomfret")
    } else if name.contains("rumsey hall") {
        return #imageLiteral(resourceName: "RumseyHall")
    } else if name.contains("sacred heart") {
        return #imageLiteral(resourceName: "SacredHeartG")
    } else if name.contains("south kent") {
        return #imageLiteral(resourceName: "SouthKent")
    } else if name.contains("suffield") {
        return #imageLiteral(resourceName: "Suffield")
    } else if name.contains("trinity-pawling") {
        return #imageLiteral(resourceName: "TP")
    } else if name.contains("westminster") {
        return #imageLiteral(resourceName: "Westminster")
    } else if name.contains("westover") {
        return #imageLiteral(resourceName: "Westover")
    } else if name.contains("wilbraham") {
        return #imageLiteral(resourceName: "Wilbraham _ Monson Academy")
    } else if name.contains("williston") {
        return #imageLiteral(resourceName: "Williston")
    } else if name.contains("worcester") {
        return #imageLiteral(resourceName: "Worcester")
    } else if name.contains("alabany academy") {
        return #imageLiteral(resourceName: "AlbanyAcademy")
    } else if name.contains("avon old farm") {
        return #imageLiteral(resourceName: "Avon")
    } else if name.contains("brunswick") {
        return #imageLiteral(resourceName: "Brunswick")
    } else if name.contains("canterbury") {
        return #imageLiteral(resourceName: "Canterbury")
    } else if name.contains("cheshire") {
        return #imageLiteral(resourceName: "Chershire")
    } else if name.contains("choate") {
        return #imageLiteral(resourceName: "Choate")
    } else if name.contains("deerfield") {
        return #imageLiteral(resourceName: "Deerfield")
    } else if name.contains("dexter") {
        return #imageLiteral(resourceName: "DexterSouthfield")
    } else if name.contains("ethel walker") {
        return #imageLiteral(resourceName: "Ethel-Walker")
    } else if name.contains("greenwich") {
        return #imageLiteral(resourceName: "GreenwichAcademy")
    } else if name.contains("gunnery") {
        return #imageLiteral(resourceName: "Gunnery")
    } else if name.contains("ims") {
        return #imageLiteral(resourceName: "IMS")
    } else if name.contains("kent") {
        return #imageLiteral(resourceName: "Kent")
    } else if name.contains("kingswood") {
        return #imageLiteral(resourceName: "KingswoodOxford")
    } else if name.contains("loomis") {
        return #imageLiteral(resourceName: "Loomis")
    } else if name.contains("lyme") {
        return #imageLiteral(resourceName: "Lyme")
    } else if name.contains("millbrook") {
        return #imageLiteral(resourceName: "Millbrook")
    } else {
      return #imageLiteral(resourceName: "Generic_School")
    }
  }
}
