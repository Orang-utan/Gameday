//
//  GamePostModelUtils.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 4/11/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import RxSwift
import ObjectMapper

extension GamePostModel {
  static func likeGame(originalGame: GamePostModel) -> Single<GamePostModel?> {
    var originalGame = originalGame
    let gameRef = db.collection("game_posts").document(originalGame.id)

    return db.rx.runTransaction({ (transaction, _) -> Any? in
      do {
        guard let data = try transaction.getDocument(gameRef).data() else { return nil }
        let game = try Mapper<GamePostModel>().map(JSON: data)
        let newLikesCount = game.likesCount + 1
        var newLikeUsersId = game.likeUsersId
        newLikeUsersId[CURRENT_USER_ID] = true

        originalGame.likesCount = newLikesCount
        originalGame.likeUsersId = newLikeUsersId

        transaction.updateData(["likes_count": newLikesCount,
                                "like_users_id": newLikeUsersId], forDocument: gameRef)
      } catch let error {
        print(error)
      }

      return originalGame
    })
      .map { $0 as? GamePostModel }
  }

  static func rsvpGame(originalGame: GamePostModel) -> Single<GamePostModel?> {
    var originalGame = originalGame
    let gameRef = db.collection("game_posts").document(originalGame.id)

    return db.rx.runTransaction({ (transaction, _) -> Any? in
      do {
        guard let data = try transaction.getDocument(gameRef).data() else { return nil }
        let game = try Mapper<GamePostModel>().map(JSON: data)
        var newFansCount = game.isFan ? game.fansCount - 1 : game.fansCount + 1
        newFansCount = newFansCount < 0 ? 0 : newFansCount
        var newFanUsersId = game.fanUsersId
        newFanUsersId[CURRENT_USER_ID] = game.isFan ? nil : true

        originalGame.fansCount = newFansCount
        originalGame.fanUsersId = newFanUsersId

        transaction.updateData(["fans_count": newFansCount,
                                "fan_users_id": newFanUsersId], forDocument: gameRef)
      } catch let error {
        print(error)
      }

      return originalGame
    })
      .map { $0 as? GamePostModel }
  }

  static func deleteGame(game: GamePostModel) -> Single<Void> {
    return db.collection("game_posts").document(game.id).rx.delete()
  }
}
