//
//  UserProfile.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import Foundation

class UserProfile {
    var uid: String
    var username: String
    var photoURL:URL
    
    init(uid: String, username: String, photoURL: URL) {
        self.uid = uid
        self.username = username
        self.photoURL = photoURL
    }
}
