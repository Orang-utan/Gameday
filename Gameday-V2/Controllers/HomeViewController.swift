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
  @IBOutlet weak var noGamesView: UIView!

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
    self.tableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "GameTableViewCell")

    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white], for: .normal)
    self.searchBar.delegate = self
    
    let logo = #imageLiteral(resourceName: "Gameday Logo")
    let imageView = UIImageView(image:logo)
    imageView.contentMode = .scaleAspectFit
    self.navigationItem.titleView = imageView

    self.formatter.dateFormat = "E, MMM dd"

    self.dateFilterButton.setTitle("Today", for: UIControlState.normal)
    
    noGamesView.isHidden = true
    
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.viewSwiped))
    swipeRight.direction = UISwipeGestureRecognizerDirection.right
    self.view.addGestureRecognizer(swipeRight)
    
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.viewSwiped))
    swipeLeft.direction = UISwipeGestureRecognizerDirection.left
    self.view.addGestureRecognizer(swipeLeft)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(showCreateGame), name: Notification.Name(rawValue: "addGameTabBarTapped"), object: nil)
    self.getDatas()
  }

  @objc func viewSwiped(_ sender: UISwipeGestureRecognizer) {
    switch sender.direction {
    case UISwipeGestureRecognizerDirection.right:
      print("SWIPED RIGHT")
      self.currentFilterDate = self.currentFilterDate.subtract(1.days)
      self.setupFilterDateTitle()
      self.loadFilter()
    case UISwipeGestureRecognizerDirection.left:
      print("SWIPED LEFT")
      self.currentFilterDate = self.currentFilterDate.add(1.days)
      self.setupFilterDateTitle()
      self.loadFilter()
    default:
      break
    }
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
    
    if filteredGames.count == 0 {
      noGamesView.isHidden = false
      tableView.isScrollEnabled = false
    } else {
      noGamesView.isHidden = true
      tableView.isScrollEnabled = true
    }
    
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


  @IBAction func openCalendarTapped(_ sender: UITapGestureRecognizer) {
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath) as! GameTableViewCell
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
    let originalGame = self.filteredGames[index]
    guard originalGame.isLiked == false else { return }

    GamePostModel.likeGame(originalGame: originalGame)
      .subscribe(onSuccess: { [weak self] (game) in
        guard let `self` = self, let game = game else { return }
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
    let originalGame = self.filteredGames[index]

    GamePostModel.rsvpGame(originalGame: originalGame)
      .subscribe(onSuccess: { [weak self] (game) in
        guard let `self` = self, let game = game else { return }
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

  func didPressedDeleteButton(cell: UITableViewCell) {
    guard let index = self.tableView.indexPath(for: cell)?.row else { return }
    let game = self.filteredGames[index]
    SVProgressHUD.show(withStatus: "Deleting...")

    GamePostModel.deleteGame(game: game)
      .subscribe(onSuccess: { [weak self] in
        guard let `self` = self else { return }

        self.filteredGames.remove(at: index)
        if let index = self.games.index(where: { $0.id == game.id }) {
          self.games.remove(at: index)
        }
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        SVProgressHUD.showSuccess(withStatus: "Deleted")
        SVProgressHUD.dismiss(withDelay: 2)
        }, onError: { (error) in
          SVProgressHUD.showError(withStatus: error.localizedDescription)
      })
      .disposed(by: rx.disposeBag)
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

