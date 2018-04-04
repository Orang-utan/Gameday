//
//  GameTableViewCell.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {

  @IBOutlet weak var userProfile: UIImageView!
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var postTime: UILabel!

  @IBOutlet weak var bgView: UIView!

  @IBOutlet weak var gameTitleLabel: UILabel!

  @IBOutlet weak var homeTeamPicture: UIImageView!
  @IBOutlet weak var homeTeamLabel: UILabel!
  @IBOutlet weak var awayTeamPicture: UIImageView!
  @IBOutlet weak var awayTeamLabel: UILabel!

  @IBOutlet weak var gameTimeLabel: UILabel!
  @IBOutlet weak var dateAndLocationLabel: UILabel!

  @IBOutlet weak var rsvpLabel: UILabel!
  @IBOutlet weak var likeLabel: UILabel!

  @IBOutlet weak var deleteButton: UIButton!

  @IBOutlet weak var homeScoreLabel: UILabel!
  @IBOutlet weak var awayScoreLabel: UILabel!
  @IBOutlet weak var finalLabel: UILabel!

  private let formatter = DateFormatter()

  var model: GamePostModel! {
    didSet {
      //by default, delete button is hidden
      self.deleteButton.isHidden = !(model.authorId == CURRENT_USER_ID)

      self.userProfile.loadImage(url: model.author?.photoURL)

      self.userName.text = model.author?.displayName

      self.homeTeamLabel.text = model.homeTeam.name
      self.homeTeamPicture.image = model.homeTeam.teamImage

      self.awayTeamLabel.text = model.awayTeam.name
      self.awayTeamPicture.image = model.awayTeam.teamImage

      self.gameTitleLabel.text = model.gameTitle

      self.formatter.dateFormat = "h:mm a"
      self.gameTimeLabel.text = self.formatter.string(from: model.startDate)
      self.formatter.dateFormat = "MMMM dd"
      self.dateAndLocationLabel.text = "\(self.formatter.string(from: model.startDate)) @ \(model.place)"

      self.postTime.text = model.createAt.timeAgoSinceNow

      if model.status == MatchStatus.upcomming {
        self.finalLabel.isHidden = true
        self.homeScoreLabel.superview?.isHidden = true
        self.bgView.backgroundColor = UIColor(hex: 0x30CB9B)
      } else if model.status == MatchStatus.live {
        self.finalLabel.isHidden = true
        self.homeScoreLabel.superview?.isHidden = false
        self.bgView.backgroundColor = UIColor.orange
      } else {
        self.finalLabel.isHidden = false
        self.homeScoreLabel.superview?.isHidden = false
        self.bgView.backgroundColor = UIColor.red
      }

      self.homeScoreLabel.text = String(model.homeTeam.score)
      self.awayScoreLabel.text = String(model.awayTeam.score)
      self.homeScoreLabel.superview?.backgroundColor = self.bgView.backgroundColor

//      let likeNumber = NSMutableAttributedString(string: "\(game.like)", attributes:attrs_black)
//      let like = (NSMutableAttributedString(string:" Likes", attributes:attrs_gray))
//      likeNumber.append(like)
//      cell.likeLabel.attributedText = likeNumber
//
//      let fansNumber = NSMutableAttributedString(string: "\(game.rsvp.count)", attributes:attrs_black)
//      let fans = (NSMutableAttributedString(string:" Fans", attributes:attrs_gray))
//      fansNumber.append(fans)
//      cell.rsvpLabel.attributedText = fansNumber
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    userProfile.layer.cornerRadius = userProfile.bounds.height / 2
    userProfile.clipsToBounds = true
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    self.finalLabel.isHidden = true
    self.homeScoreLabel.superview?.isHidden = true
  }

  @IBAction func rsvpTapped(_ sender: UIButton) {
    print("RSVPed")
  }

  @IBAction func likeTapped(_ sender: UIButton) {
    print("Liked")
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
