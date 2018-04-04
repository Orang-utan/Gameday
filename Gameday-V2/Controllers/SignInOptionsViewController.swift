//
//  SignInOptionsViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class SignInOptionsViewController: UIViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var googleSigninButton: GIDSignInButton!

  private var authUI: FUIAuth?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.pushToHomeControllerIfNeeded()

    emailTextField.borderStyle = UITextBorderStyle.roundedRect
    passwordTextField.borderStyle = UITextBorderStyle.roundedRect
    loginButton.layer.cornerRadius = 5
    googleSigninButton.layer.masksToBounds = true
    googleSigninButton.layer.cornerRadius = 5

    authUI = FUIAuth.defaultAuthUI()
    authUI?.delegate = self
    authUI?.isSignInWithEmailHidden = true
    authUI?.providers = [FUIGoogleAuth()]

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(googleButtonPressed(_:)))
    googleSigninButton.addGestureRecognizer(tapGesture)
    googleSigninButton.isUserInteractionEnabled = true
  }

  private func pushToHomeControllerIfNeeded() {
    guard Auth.auth().currentUser != nil else { return }
    let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
    UIApplication.shared.delegate?.window??.rootViewController = controller
  }

  private func updateUserInfoToFirestore() {
    guard let user = Auth.auth().currentUser else { return }
    var data: [String: Any] = ["id": user.uid]
    data["email"] = user.email
    data["display_name"] = user.displayName
    data["photo_url"] = user.photoURL?.absoluteString
    data["creation_date"] = user.metadata.creationDate

    db.collection("users").document(user.uid).setData(data, options: SetOptions.merge()) { (error) in
      if let error = error { print(error) }
      self.pushToHomeControllerIfNeeded()
    }
  }

  @IBAction func loginTapped(_ sender: UIButton) {
    guard let email = emailTextField.text else { return }
    guard let password = passwordTextField.text else { return }

    Auth.auth().signIn(withEmail: email, password: password, completion: {
      user, error in
      if user != nil, error == nil {
        self.updateUserInfoToFirestore()
        print("logged in")
      } else {
        print("error logging in: \(error!.localizedDescription)")
      }
    })
  }

  @IBAction func bgViewTapped(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @objc func googleButtonPressed(_ sender: Any) {
    guard let authController = self.authUI?.authViewController() else { return }
    self.present(authController, animated: true, completion: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }
}

extension SignInOptionsViewController: FUIAuthDelegate {
  func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
    if let error = error { print(error) }
    self.updateUserInfoToFirestore()
  }
}
