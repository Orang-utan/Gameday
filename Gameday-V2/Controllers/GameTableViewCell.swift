//
//  GameTableViewCell.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit

protocol GameTableViewCellDelegate: class {
  func didPressedLikeButton(cell: UITableViewCell)
  func didPressedRSVPButton(cell: UITableViewCell)
}

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

  let attrs_black = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : UIColor.black]
  let attrs_gray = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : UIColor.gray]
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

      let isUpcomingStatus = model.status == MatchStatus.upcomming
      self.dateAndLocationLabel.isHidden = !isUpcomingStatus
      self.homeScoreLabel.superview?.isHidden = isUpcomingStatus
      self.finalLabel.isHidden = !(model.status == MatchStatus.final)

      self.homeScoreLabel.text = String(model.homeTeam.score)
      self.awayScoreLabel.text = String(model.awayTeam.score)

      if model.status == MatchStatus.upcomming {
        self.bgView.backgroundColor = UIColor(hex: 0x30CB9B)
      } else if model.status == MatchStatus.live {
        self.bgView.backgroundColor = UIColor.orange
      } else {
        self.bgView.backgroundColor = UIColor.red
      }

      self.homeScoreLabel.superview?.backgroundColor = self.bgView.backgroundColor


      let likeNumber = NSMutableAttributedString(string: "\(model.likesCount)", attributes: attrs_black)
      let like = NSMutableAttributedString(string:" Likes", attributes: attrs_gray)
      likeNumber.append(like)
      self.likeLabel.attributedText = likeNumber

      let fansNumber = NSMutableAttributedString(string: "\(model.fansCount)", attributes:attrs_black)
      let fans = NSMutableAttributedString(string:" Fans", attributes:attrs_gray)
      fansNumber.append(fans)
      self.rsvpLabel.attributedText = fansNumber
    }
  }
  weak var delegate: GameTableViewCellDelegate?

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
    self.delegate?.didPressedRSVPButton(cell: self)
  }

  @IBAction func likeTapped(_ sender: UIButton) {
    self.delegate?.didPressedLikeButton(cell: self)
  }

}
