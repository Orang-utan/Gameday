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

class SignInOptionsViewController: UIViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var googleSigninButton: GIDSignInButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()

    self.pushToHomeControllerIfNeeded()

    emailTextField.borderStyle = UITextBorderStyle.roundedRect
    passwordTextField.borderStyle = UITextBorderStyle.roundedRect
    loginButton.layer.cornerRadius = 5
    googleSigninButton.layer.masksToBounds = true
    googleSigninButton.layer.cornerRadius = 5

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(googleButtonPressed(_:)))
    googleSigninButton.addGestureRecognizer(tapGesture)
    googleSigninButton.isUserInteractionEnabled = true

    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self

    

  }

  private func pushToHomeControllerIfNeeded() {
    guard Auth.auth().currentUser != nil else { return }
    print("Show tutorial here")
    
    performSegue(withIdentifier: "signInToTutorialSegue", sender: self)
    
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

    if let fcmToken = Messaging.messaging().fcmToken {
      data["fcm_token"] = fcmToken
    }

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
        var title = ""
        var message = ""
        
        if let error = error as NSError? {
            guard let errorCode = AuthErrorCode(rawValue: error.code) else {
                print("there was an error logging in but it could not be matched with a firebase code")
                return
            }
            switch errorCode {
            case .wrongPassword:
                title = "Oops..."
                message = "Invalid email or password. Try again."
            case .invalidEmail:
                title = "Oops..."
                message = "Invalid email. Try again."
            default:
                title = "Oops..."
                message = "An unknown occured just now. Please try again later."
            }
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    GIDSignIn.sharedInstance().signIn()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }
}

extension SignInOptionsViewController: GIDSignInDelegate {
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if let error = error {
      print(error)
      return
    }

    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)
    Auth.auth().signIn(with: credential) { (user, error) in
      if user != nil, error == nil {
        self.updateUserInfoToFirestore()
        
        print("logged in")
      } else {
        var title = ""
        var message = ""

        if let error = error as NSError? {
            guard let errorCode = AuthErrorCode(rawValue: error.code) else {
                print("there was an error logging in but it could not be matched with a firebase code")
                return
            }
            switch errorCode {
                case .wrongPassword:
                    title = "Oops..."
                    message = "Invalid email or password. Try again."
                case .invalidEmail:
                    title = "Oops..."
                    message = "Invalid email. Try again."
                default:
                    title = "Oops..."
                    message = "An unknown occured just now. Please try again later."
            }
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    }
  }
}

extension SignInOptionsViewController: GIDSignInUIDelegate {
}
