//
//  ViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 3/31/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import Firebase
import RxSwift
import SVProgressHUD

class HomeViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var timeSegmentControl: UISegmentedControl!

  var data: [SportsGame] = []
  private var games: [GamePostModel] = []
  private var filteredGames: [GamePostModel] = []

  let attrs_black = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : UIColor.black]
  let attrs_gray = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : UIColor.gray]

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self

    timeSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment
    timeSegmentControl.layer.cornerRadius = 0
    timeSegmentControl.addTarget(self, action: #selector(segmentControlDidPressed), for: UIControlEvents.valueChanged)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.getDatas()
  }

  private func getDatas() {
    if self.games.isEmpty {
      SVProgressHUD.show()
    }
    db.collection("game_posts")
      .rx.getDocuments()
      .map { $0.documents }
      .mapArray(type: GamePostModel.self)
      .flatMap({ (games) -> Single<[GamePostModel]> in
        let obs = games.map { game -> Observable<GamePostModel> in
          return db.collection("users").document(game.authorId)
            .rx.getDocument()
            .map(type: UserModel.self)
            .map { (user) -> GamePostModel in
              var game = game
              game.author = user
              return game
            }
            .asObservable()
        }
        return Observable.zip(obs).asSingle()
      })
      .subscribe(onSuccess: { [weak self] (games) in
        SVProgressHUD.dismiss()
        self?.games = games
        self?.filteredGames = games
        self?.tableView.reloadData()
        }, onError: { (error) in
          print(error)
      })
      .disposed(by: rx.disposeBag)
  }

  @objc func segmentControlDidPressed() {
    if timeSegmentControl.selectedSegmentIndex == UISegmentedControlNoSegment {
      self.filteredGames = self.games
    } else if timeSegmentControl.selectedSegmentIndex == 0 {
      self.filteredGames = self.games.filter { $0.status == MatchStatus.upcomming }
    } else if timeSegmentControl.selectedSegmentIndex == 1 {
      self.filteredGames = self.games.filter { $0.status == MatchStatus.live }
    } else {
      self.filteredGames = self.games.filter { $0.status == MatchStatus.final }
    }

    self.tableView.reloadData()
  }

  @IBAction func createGameTapped(_ sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "HomeToCreateSegue", sender: self)
  }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameTableViewCell
    cell.model = self.filteredGames[indexPath.row]
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let model = self.filteredGames[indexPath.row]
    guard model.status == MatchStatus.live else { return }
    let detailNaviVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailsNavigationController") as! UINavigationController
    let detailVC = detailNaviVC.viewControllers.first as! DetailsViewController
    detailVC.model = model
    self.present(detailNaviVC, animated: true, completion: nil)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 265
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.filteredGames.count
  }

}

