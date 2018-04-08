//
//  DetailsViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD

class DetailsViewController: UIViewController {

  @IBOutlet weak var homeScoreTextField: UILabel!
  @IBOutlet weak var awayScoreTextField: UILabel!
  @IBOutlet weak var homeTeamNameLabel: UILabel!
  @IBOutlet weak var awayTeamNameLabel: UILabel!
    
  @IBOutlet weak var homeAddButton: UIButton!
  @IBOutlet weak var homeSubtractButton: UIButton!
    
  @IBOutlet weak var awayAddButton: UIButton!
  @IBOutlet weak var awaySubtractButton: UIButton!

  var model: GamePostModel!
  private var localHomeScore = 0
  private var localAwayScore = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    
    homeScoreTextField.layer.cornerRadius = 7
    homeScoreTextField.clipsToBounds = true
    
    awayScoreTextField.layer.cornerRadius = 7
    awayScoreTextField.clipsToBounds = true
    
    homeAddButton.layer.cornerRadius = 7
    homeAddButton.clipsToBounds = true
    
    homeSubtractButton.layer.cornerRadius = 7
    homeSubtractButton.clipsToBounds = true
    
    awayAddButton.layer.cornerRadius = 7
    awayAddButton.clipsToBounds = true
    
    awaySubtractButton.layer.cornerRadius = 7
    awaySubtractButton.clipsToBounds = true

    self.updateUI()

    db.collection("game_posts").document(self.model.id)
      .rx.listen()
      .map { try Mapper<GamePostModel>().map(JSON: $0.data() ?? [:]) }
      .subscribe(onNext: { [weak self] in
        self?.model = $0
        self?.updateUI()
      })
      .disposed(by: rx.disposeBag)
  }

  private func updateUI() {
    self.homeTeamNameLabel.text = self.model.homeTeam.name
    self.awayTeamNameLabel.text = self.model.awayTeam.name
    self.homeScoreTextField.text = String(self.model.homeTeam.score)
    self.awayScoreTextField.text = String(self.model.awayTeam.score)

    self.localHomeScore = self.model.homeTeam.score
    self.localAwayScore = self.model.awayTeam.score
  }

  @IBAction func plusHomeButtonPressed(_ sender: Any) {
    self.localHomeScore += 1
    self.homeScoreTextField.text = String(self.localHomeScore)
  }

  @IBAction func plusAwayButtonPressed(_ sender: Any) {
    self.localAwayScore += 1
    self.awayScoreTextField.text = String(self.localAwayScore)
  }

  @IBAction func minusHomeButtonPressed(_ sender: Any) {
    self.localHomeScore -= 1
    self.localHomeScore = self.localHomeScore < 0 ? 0 : self.localHomeScore
    self.homeScoreTextField.text = String(self.localHomeScore)
  }

  @IBAction func minusAwayButtonPressed(_ sender: Any) {
    self.localAwayScore -= 1
    self.localAwayScore = self.localAwayScore < 0 ? 0 : self.localAwayScore
    self.awayScoreTextField.text = String(self.localAwayScore)
  }

  @IBAction func saveScoreButtonPressed(_ sender: Any) {
    guard self.localHomeScore != self.model.homeTeam.score || self.localAwayScore != self.model.awayTeam.score else {
      SVProgressHUD.showError(withStatus: "You can't update same score")
      return
    }

    SVProgressHUD.show()
    let data = ["home_team.score": self.localHomeScore, "away_team.score": self.localAwayScore]
    db.collection("game_posts").document(self.model.id).updateData(data) { (error) in
      SVProgressHUD.dismiss()
      if let error = error { print(error) }
      self.dismiss(animated: true, completion: nil)
    }
  }

  @IBAction func backTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }

}
