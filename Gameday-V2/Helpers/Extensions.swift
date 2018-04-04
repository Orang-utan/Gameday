//
//  Extensions.swift
//  Pima
//
//  Created by Tuan Nguyen on 2/1/18.
//  Copyright © 2018 Antonino Febbraro. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation
import MapKit
import RxSwift
import FirebaseFirestore

extension UIColor {
  @nonobjc class var pmSapphire: UIColor {
    return UIColor(red: 48.0 / 255.0, green: 35.0 / 255.0, blue: 174.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var pmPurplishPink: UIColor {
    return UIColor(red: 213.0 / 255.0, green: 82.0 / 255.0, blue: 187.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var pmWhite: UIColor {
    return UIColor(white: 255.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var pmWhiteTwo: UIColor {
    return UIColor(white: 245.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var pmDark: UIColor {
    return UIColor(red: 36.0 / 255.0, green: 37.0 / 255.0, blue: 61.0 / 255.0, alpha: 1.0)
  }

  convenience init(hex: Int) {
    let components = (
      R: CGFloat((hex >> 16) & 0xff) / 255,
      G: CGFloat((hex >> 08) & 0xff) / 255,
      B: CGFloat((hex >> 00) & 0xff) / 255
    )

    self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
  }
}

extension String {
  static func randomStringWithLength(length: Int = 16) -> String {
    let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789"
    let randomString = NSMutableString(capacity: length)
    for _ in 0 ..< length {
      let length = UInt32 (letters.length)
      let rand = arc4random_uniform(length)
      randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    return randomString as String
  }
}

extension MKMapSnapshotter {
  class func snapshotter(location: CLLocation) -> MKMapSnapshotter {

    let mapSnapshotOptions = MKMapSnapshotOptions()

    // Set the region of the map that is rendered.
    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
    mapSnapshotOptions.region = region

    // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
    mapSnapshotOptions.scale = UIScreen.main.scale

    // Set the size of the image output.
    mapSnapshotOptions.size = CGSize(width: 300, height: 300)

    // Show buildings and Points of Interest on the snapshot
    mapSnapshotOptions.showsBuildings = true
    mapSnapshotOptions.showsPointsOfInterest = true

    return MKMapSnapshotter(options: mapSnapshotOptions)
  }
}

extension CLLocation {
  var isLessThan20Miles: Bool {
    if let currentLocation = AppData.shared.currentLocation {
      return currentLocation.distance(from: self)/1609.34 < 20
    }
    return false
  }

  func isLessThanMiles(miles: Double) -> Bool {
    if let currentLocation = AppData.shared.currentLocation {
      return currentLocation.distance(from: self)/1609.34 < miles
    }
    return false
  }

  class func getAddress(location: CLLocation, completion: @escaping ((String?) -> Void)) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
      guard error == nil, let placemark = placemarks?.first else {
        completion(nil)
        return
      }

      guard let countryName = placemark.country else {
        completion(nil)
        return
      }

      var locationName: String = ""
      if let cityName = placemark.locality, cityName.isEmpty == false {
        locationName = cityName + ", "
      } else if let cityName = placemark.subLocality, cityName.isEmpty == false {
        locationName = cityName + ", "
      } else if let cityName = placemark.administrativeArea, cityName.isEmpty == false {
        locationName = cityName + ", "
      } else if let cityName = placemark.subAdministrativeArea, cityName.isEmpty == false {
        locationName = cityName + ", "
      }

      locationName += countryName

      completion(locationName)
    })
  }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == [DocumentSnapshot] {
  func mapArray<T: ImmutableMappable>(type: T.Type) -> Single<[T]> {
    return self.map({ snapshot in snapshot.flatMap { $0.data() } })
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

extension Sequence where Iterator.Element == PinModel {
  func filterDefaultLogic() -> [PinModel] {
    let filterValue = AppData.shared.pinFilter.value
    let filterMonth = Date().add(filterValue.monthsInAdvance.months)

    var temp = self.filter { $0.isExpired == false }
      .filter { $0.kidFriendly == filterValue.isKidFriendly }
      .filter { return $0.startDate == nil ? true : $0.startDate! <= filterMonth }
      .filterBlockedPins()
      .filter {
        let location = CLLocation(latitude: $0.lat, longitude: $0.long)
        return location.isLessThan20Miles
    }

    let startRadius = 20 // start by 20 miles
    let stepJump = 10 // if can not find any pins in 20 miles, jump by step 10 miles
    let maximumRadius = 200

    var i = startRadius
    while i <= maximumRadius && temp.isEmpty {
      i += stepJump
      temp = temp.filter {
        let location = CLLocation(latitude: $0.lat, longitude: $0.long)
        return location.isLessThanMiles(miles: Double(i))
      }
    }

    return temp
  }

  func mustHaveInterestingTags() -> [PinModel] {
    guard let interestingTags = AppData.shared.currentUser?.interestingTags else {
      return self.flatMap { $0 }
    }
    return self.filter { pin in
      return pin.tags.contains(where: { interestingTags.contains($0) })
    }
  }

  func sortDefaultLogic() -> [PinModel] {
    return self.sorted(by: { (first, next) -> Bool in
      if first.itinerarysCount == next.itinerarysCount {
        return first.checkInsCount > next.checkInsCount
      }

      return first.itinerarysCount > next.itinerarysCount
    })
  }

  func filterByTitleAndTags(searchText: String) -> [PinModel] {
    let searchText = searchText.lowercased()
    return self.filter { pin in
      pin.title.lowercased().contains(searchText)
        || pin.tags.contains(where: { $0.lowercased().contains(searchText) })
    }
  }

  func filterBlockedPins() -> [PinModel] {
    return self.filter {
      if let blockPins = AppData.shared.currentUser?.blockPins {
        return blockPins.contains($0.id) == false
      }

      return true
    }
  }
}
