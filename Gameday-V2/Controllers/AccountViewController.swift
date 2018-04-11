//
//  AccountViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import RxSwift

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var userProfileImage: UIImageView!

  @IBOutlet weak var headerView: UIView!
  private let kTableHeaderHeight: CGFloat = 88

  private var games: [GamePostModel] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 0
    tableView.tableFooterView = UIView()
    self.tableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "GameTableViewCell")

    headerView = tableView.tableHeaderView
    tableView.tableHeaderView = nil
    tableView.addSubview(headerView)

    tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
    tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
    updateHeaderView()
    
    userProfileImage.layer.cornerRadius = userProfileImage.bounds.height / 2
    userProfileImage.clipsToBounds = true

    if let username = Auth.auth().currentUser?.displayName,
      let photoURL = Auth.auth().currentUser?.photoURL {
      usernameLabel.text = username
      ImageService.getImage(withURL: photoURL) {
        image in
        self.userProfileImage.image = image
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.getDatas()
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

  private func getDatas() {
    if self.games.isEmpty {
      SVProgressHUD.show()
    }
    db.collection("game_posts")
      .whereField("author_id", isEqualTo: CURRENT_USER_ID)
      .rx.getDocuments()
      .map { $0.documents }
      .mapArray(type: GamePostModel.self)
      .flatMap({ (games) -> Single<[GamePostModel]> in
        db.collection("users").document(CURRENT_USER_ID)
          .rx.getDocument()
          .map(type: UserModel.self)
          .map { (user) -> [GamePostModel] in
            let gamesWithAuthor = games.map { game -> GamePostModel in
              var game = game
              game.author = user
              return game
            }
            return gamesWithAuthor
        }
      })
      .subscribe(onSuccess: { [weak self] (games) in
        SVProgressHUD.dismiss()
        let sortedLiveGames = games.filter { $0.status == MatchStatus.live }.sorted(by: { $0.createAt > $1.createAt })
        let sortedUpcomingGames = games.filter { $0.status == MatchStatus.upcomming }.sorted(by: { $0.createAt > $1.createAt })
        let sortedFinalGames = games.filter { $0.status == MatchStatus.final }.sorted(by: { $0.createAt > $1.createAt })
        let sortedGames = sortedLiveGames + sortedUpcomingGames + sortedFinalGames
        self?.games = sortedGames
        self?.tableView.reloadData()
        }, onError: { (error) in
          print(error)
      })
      .disposed(by: rx.disposeBag)
  }


  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath) as! GameTableViewCell
    cell.model = self.games[indexPath.row]
    cell.delegate = self
    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.games.count
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 265
  }

  @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
    
    let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout of Gameday?", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
      return
    }))
    alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { action in
      try! Auth.auth().signOut()
      let loginVC = self.storyboard?.instantiateInitialViewController()
      UIApplication.shared.keyWindow?.rootViewController = loginVC
    }))
    self.present(alert, animated: true, completion: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension AccountViewController: GameTableViewCellDelegate {
  func didPressedLikeButton(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }
    let originalGame = self.games[index]
    guard originalGame.isLiked == false else { return }

    GamePostModel.likeGame(originalGame: originalGame)
      .subscribe(onSuccess: { [weak self] (game) in
        guard let `self` = self, let game = game else { return }
        self.games[index] = game
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        }, onError: { (error) in
          print(error)
      })
      .disposed(by: rx.disposeBag)
  }

  func didPressedRSVPButton(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }
    let originalGame = self.games[index]

    GamePostModel.rsvpGame(originalGame: originalGame)
      .subscribe(onSuccess: { [weak self] (game) in
        guard let `self` = self, let game = game else { return }
        self.games[index] = game
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        }, onError: { (error) in
          print(error)
      })
      .disposed(by: rx.disposeBag)
  }

  func didPressedRSVPLabel(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }
    let game = self.games[index]
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FansTableViewController") as! FansTableViewController
    vc.game = game
    self.navigationController?.pushViewController(vc, animated: true)
  }

  func didPressedDeleteButton(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }
    let game = self.games[index]
    SVProgressHUD.show(withStatus: "Deleting...")

    GamePostModel.deleteGame(game: game)
      .subscribe(onSuccess: { [weak self] in
        guard let `self` = self else { return }

        self.games.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        SVProgressHUD.showSuccess(withStatus: "Deleted")
        SVProgressHUD.dismiss(withDelay: 2)
        }, onError: { (error) in
          SVProgressHUD.showError(withStatus: error.localizedDescription)
      })
      .disposed(by: rx.disposeBag)
  }
}
