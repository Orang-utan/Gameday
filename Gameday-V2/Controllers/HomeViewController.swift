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
import ObjectMapper
import NotificationBannerSwift
import Popover

class HomeViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var dateFilterButton: UIButton!

  private var popup: Popover?
  private var currentFilterDate = Date()
  private let formatter = DateFormatter()

  var data: [SportsGame] = []
  private var games: [GamePostModel] = []
  private var filteredGames: [GamePostModel] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 0

    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white], for: .normal)
    self.searchBar.delegate = self
    
    let logo = #imageLiteral(resourceName: "Gameday Logo")
    let imageView = UIImageView(image:logo)
    imageView.contentMode = .scaleAspectFit
    self.navigationItem.titleView = imageView

    self.formatter.dateFormat = "E, MMM dd"

    self.dateFilterButton.setTitle("Today", for: UIControlState.normal)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(showCreateGame), name: Notification.Name(rawValue: "addGameTabBarTapped"), object: nil)
    self.getDatas()
  }

  @objc func showCreateGame(notification: Notification){
    performSegue(withIdentifier: "HomeToCreateSegue", sender: self)
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
        self?.loadFilter()
        }, onError: { (error) in
          print(error)
      })
      .disposed(by: rx.disposeBag)
  }

  private func setupFilterDateTitle() {
    if self.currentFilterDate.isToday {
      self.dateFilterButton.setTitle("Today", for: UIControlState.normal)
    } else if self.currentFilterDate.isTomorrow {
      self.dateFilterButton.setTitle("Tomorrow", for: UIControlState.normal)
    } else if self.currentFilterDate.isYesterday {
      self.dateFilterButton.setTitle("Yesterday", for: UIControlState.normal)
    } else {
      self.dateFilterButton.setTitle(self.formatter.string(from: self.currentFilterDate), for: UIControlState.normal)
    }
  }

  private func loadFilter() {
    let sortedLiveGames = games.filter { $0.status == MatchStatus.live }.sorted(by: { $0.createAt > $1.createAt }).filter { $0.startDate.isSameDay(date: self.currentFilterDate) }
    let sortedUpcomingGames = games.filter { $0.status == MatchStatus.upcomming }.sorted(by: { $0.createAt > $1.createAt }).filter { $0.startDate.isSameDay(date: self.currentFilterDate) }
    let sortedFinalGames = games.filter { $0.status == MatchStatus.final }.sorted(by: { $0.createAt > $1.createAt }).filter { $0.startDate.isSameDay(date: self.currentFilterDate) }
    let sortedGames = sortedLiveGames + sortedUpcomingGames + sortedFinalGames
    self.filteredGames = sortedGames
    self.tableView.reloadData()
  }

  @IBAction func createGameTapped(_ sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "HomeToCreateSegue", sender: self)
  }

  @IBAction func searchButtonPressed(_ sender: Any) {
    let isOpenned = self.searchTopConstraint.constant == 0
    self.searchTopConstraint.constant = isOpenned ? -56 : 0
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

  @IBAction func nextDateButtonPressed(_ sender: Any) {
    self.currentFilterDate = self.currentFilterDate.add(1.days)
    self.setupFilterDateTitle()
    self.loadFilter()
  }

  @IBAction func previousDateButtonPressed(_ sender: Any) {
    self.currentFilterDate = self.currentFilterDate.subtract(1.days)
    self.setupFilterDateTitle()
    self.loadFilter()
  }

  @IBAction func openCalendarButtonPressed(_ sender: Any) {
    let calendarView = CalendarView(frame: CGRect(x: 0, y: 0, width: 320, height: 350))
    calendarView.selectDate = self.currentFilterDate
    calendarView.delegate = self
    let popover = Popover(options: [PopoverOption.arrowSize(CGSize(width: 50, height: 20))])
    popover.show(calendarView, fromView: self.dateFilterButton.superview!)
    self.popup = popover
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
    let model = self.filteredGames[indexPath.row]
    guard model.status == MatchStatus.live else {
      var banner_title = ""
      if model.status == MatchStatus.upcomming {
        banner_title = "Game hasn't started yet. Please come back later."
      } else if model.status == MatchStatus.final {
        banner_title = "Game has already ended."
      }
      let banner = StatusBarNotificationBanner(title: banner_title, style: .warning)
      let numberOfBanners = NotificationBannerQueue.default.numberOfBanners
      print(numberOfBanners)
      if numberOfBanners == 1 {
        return
      }
      banner.dismiss()
      banner.autoDismiss = false
      banner.onTap = {
        banner.dismiss()
      }
      banner.show()
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        banner.dismiss()
      })

      return
    }
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
    var originalGame = self.filteredGames[index]
    guard originalGame.isLiked == false else { return }
    let gameRef = db.collection("game_posts").document(originalGame.id)

    db.rx.runTransaction({ (transaction, _) -> Any? in
      do {
        guard let data = try transaction.getDocument(gameRef).data() else { return nil }
        let game = try Mapper<GamePostModel>().map(JSON: data)
        let newLikesCount = game.likesCount + 1
        var newLikeUsersId = game.likeUsersId
        newLikeUsersId[CURRENT_USER_ID] = true

        originalGame.likesCount = newLikesCount
        originalGame.likeUsersId = newLikeUsersId

        transaction.updateData(["likes_count": newLikesCount,
                                "like_users_id": newLikeUsersId], forDocument: gameRef)
      } catch let error {
        print(error)
      }

      return originalGame
    })
      .subscribe(onSuccess: { [weak self] (result) in
        guard let `self` = self, let game = result as? GamePostModel else { return }
        self.filteredGames[index] = game
        if let index = self.games.index(where: { $0.id == game.id }) {
          self.games[index] = game
        }
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        }, onError: { (error) in
          print(error)
      })
      .disposed(by: rx.disposeBag)
  }

  func didPressedRSVPButton(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }
    var originalGame = self.filteredGames[index]
    let gameRef = db.collection("game_posts").document(originalGame.id)

    db.rx.runTransaction({ (transaction, _) -> Any? in
      do {
        guard let data = try transaction.getDocument(gameRef).data() else { return nil }
        let game = try Mapper<GamePostModel>().map(JSON: data)
        var newFansCount = game.isFan ? game.fansCount - 1 : game.fansCount + 1
        newFansCount = newFansCount < 0 ? 0 : newFansCount
        var newFanUsersId = game.fanUsersId
        newFanUsersId[CURRENT_USER_ID] = game.isFan ? nil : true

        originalGame.fansCount = newFansCount
        originalGame.fanUsersId = newFanUsersId

        transaction.updateData(["fans_count": newFansCount,
                                "fan_users_id": newFanUsersId], forDocument: gameRef)
      } catch let error {
        print(error)
      }

      return originalGame
    })
      .subscribe(onSuccess: { [weak self] (result) in
        guard let `self` = self, let game = result as? GamePostModel else { return }
        self.filteredGames[index] = game
        if let index = self.games.index(where: { $0.id == game.id }) {
          self.games[index] = game
        }
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        }, onError: { (error) in
          print(error)
      })
      .disposed(by: rx.disposeBag)
  }

  func didPressedRSVPLabel(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }
    let game = self.filteredGames[index]
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FansTableViewController") as! FansTableViewController
    vc.game = game
    self.navigationController?.pushViewController(vc, animated: true)
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
    self.loadFilter()
  }
}

extension HomeViewController: CalendarViewDelegate {
  func didSelectedDate(date: Date) {
    if date.isSameDay(date: self.currentFilterDate) == false {
      self.popup?.dismiss()
    }
    self.currentFilterDate = date
    self.setupFilterDateTitle()
    self.loadFilter()
  }
}

