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
        
        emailTextField.borderStyle = UITextBorderStyle.roundedRect
        passwordTextField.borderStyle = UITextBorderStyle.roundedRect
        loginButton.layer.cornerRadius = 5
        googleSigninButton.layer.masksToBounds = true
        googleSigninButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            user, error in
            if error == nil && user != nil {
                if let user = Auth.auth().currentUser {

                }
                print("logged in")
            } else {
                print("error logging in: \(error?.localizedDescription)")
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

}
