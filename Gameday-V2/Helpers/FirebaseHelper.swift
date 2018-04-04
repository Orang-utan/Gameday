//
//  FirebaseHelper.swift
//
//
//  Created by Tuan Nguyen on 10/28/17.
//  Copyright © 2017 Tuan Nguyen. All rights reserved.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

let db = Firestore.firestore()
let storageRef = Storage.storage().reference()
var CURRENT_USER_ID: String {
  return Auth.auth().currentUser?.uid ?? "-1"
}
var myDocumentRef: DocumentReference {
  return db.collection("users").document(CURRENT_USER_ID)
}

let storageStaticUrl = "https://firebasestorage.googleapis.com/v0/b/berkshiregameday.appspot.com/o/"
