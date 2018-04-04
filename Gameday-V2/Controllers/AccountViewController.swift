//
//  AccountViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var userProfileImage: UIImageView!

  @IBOutlet weak var headerView: UIView!
  private let kTableHeaderHeight: CGFloat = 88

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self

    headerView = tableView.tableHeaderView
    tableView.tableHeaderView = nil
    tableView.addSubview(headerView)

    tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
    tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
    updateHeaderView()
    
    userProfileImage.layer.cornerRadius = userProfileImage.bounds.height / 2
    userProfileImage.clipsToBounds = true

    guard let userProfile = UserService.currentUserProfile else {
      return
    }

    ImageService.getImage(withURL: userProfile.photoURL) {
      image in
      self.userProfileImage.image = image
    }

    usernameLabel.text = userProfile.username
  }

  func updateHeaderView() {
    var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
    if tableView.contentOffset.y < -kTableHeaderHeight {
      headerRect.origin.y = tableView.contentOffset.y
      headerRect.size.height = -tableView.contentOffset.y
    }
    headerView.frame = headerRect
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    updateHeaderView()
  }


  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 265
  }

  @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
    try! Auth.auth().signOut()
    let loginVC = self.storyboard?.instantiateInitialViewController()
    UIApplication.shared.keyWindow?.rootViewController = loginVC
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}
