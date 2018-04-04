//
//  Extensions.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 2/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
import FirebaseFirestore
import Nuke

extension UIColor {
  convenience init(hex: Int) {
    let components = (
      R: CGFloat((hex >> 16) & 0xff) / 255,
      G: CGFloat((hex >> 08) & 0xff) / 255,
      B: CGFloat((hex >> 00) & 0xff) / 255
    )

    self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
  }
}

extension UIImageView {
  func loadImage(url: String?) {
    guard let urlString = url, let url = URL(string: urlString) else { return }
    Nuke.Manager.shared.loadImage(with: url, into: self)
  }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == [DocumentSnapshot] {
  func mapArray<T: ImmutableMappable>(type: T.Type) -> Single<[T]> {
    return self.map({ snapshot in snapshot.compactMap { $0.data() } })
      .map({ try Mapper<T>().mapArray(JSONArray: $0) })
      .catchError({ _ in Single.just([]) })
  }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == DocumentSnapshot {
  func map<T: ImmutableMappable>(type: T.Type) -> Single<T?> {
    return self.map { $0.data() }
      .map({
        let data = $0 ?? [:]
        return Mapper<T>().map(JSON: data)
      })
      .catchError({ _ in Single.just(nil) })
  }
}
