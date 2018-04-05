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
  @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var searchBar: UISearchBar!

  var data: [SportsGame] = []
  private var games: [GamePostModel] = []
  private var filteredGames: [GamePostModel] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 0

    timeSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment
    timeSegmentControl.layer.cornerRadius = 0
    timeSegmentControl.addTarget(self, action: #selector(segmentControlDidPressed), for: UIControlEvents.valueChanged)

    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white], for: .normal)
    self.searchBar.delegate = self
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
        let sortedLiveGames = games.filter { $0.status == MatchStatus.live }.sorted(by: { $0.createAt > $1.createAt })
        let sortedUpcomingGames = games.filter { $0.status == MatchStatus.upcomming }.sorted(by: { $0.createAt > $1.createAt })
        let sortedFinalGames = games.filter { $0.status == MatchStatus.final }.sorted(by: { $0.createAt > $1.createAt })
        let sortedGames = sortedLiveGames + sortedUpcomingGames + sortedFinalGames
        self?.games = sortedGames
        self?.filteredGames = sortedGames
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
      self.filteredGames = self.games.filter { $0.startDate.isToday }
    } else {
      self.filteredGames = self.games.filter { $0.status == MatchStatus.final }
    }

    self.tableView.reloadData()
  }

  @IBAction func createGameTapped(_ sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "HomeToCreateSegue", sender: self)
  }

  @IBAction func searchButtonPressed(_ sender: Any) {
    let isOpenned = self.searchTopConstraint.constant == 0
    self.searchTopConstraint.constant = isOpenned ? -40 : 0
    if isOpenned {
      self.view.endEditing(true)
    } else {
      self.searchBar.isHidden = isOpenned
    }
    UIView.animate(withDuration: 0.25, animations: {
      self.view.layoutIfNeeded()
    }, completion: { _ in
      if isOpenned {
        self.searchBar.isHidden = isOpenned
      } else {
        self.searchBar.becomeFirstResponder()
      }
    })
  }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.filteredGames.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameTableViewCell
    cell.model = self.filteredGames[indexPath.row]
    cell.delegate = self
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
}

extension HomeViewController: GameTableViewCellDelegate {
  func didPressedLikeButton(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }
    let game = self.filteredGames[index]
    db.collection("game_posts").document(game.id)
      .rx.getDocument()
      .map(type: GamePostModel.self)
      .flatMap { (game) -> Single<Void> in
        var likesCount = game?.isLiked ?
        return Single.just(())
    }
  }

  func didPressedRSVPButton(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }

  }
}

extension HomeViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    let searchText = searchText.lowercased()
    self.filteredGames = self.games.filter {
      $0.gameTitle.lowercased().contains(searchText)
        || $0.homeTeam.name.lowercased().contains(searchText)
        || $0.awayTeam.name.lowercased().contains(searchText)
    }
    self.tableView.reloadData()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    self.view.endEditing(true)
    self.searchButtonPressed(self)
    self.segmentControlDidPressed()
  }
}

