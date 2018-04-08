//
//  GameTableViewCell.swift
//  Gameday-V2
//
//  Created by Daniel on 4/1/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import SVProgressHUD
import NotificationBannerSwift

protocol GameTableViewCellDelegate: class {
  func didPressedLikeButton(cell: UITableViewCell)
  func didPressedRSVPButton(cell: UITableViewCell)
  func didPressedRSVPLabel(cell: UITableViewCell)
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

  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var rsvpButton: UIButton!

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
      self.finalLabel.isHidden = !(model.status == MatchStatus.final || model.status == MatchStatus.live)

      self.homeScoreLabel.text = String(model.homeTeam.score)
      self.awayScoreLabel.text = String(model.awayTeam.score)

        if model.isLiked {
            likeButton.setImage(#imageLiteral(resourceName: "Clap_Filled"), for: .normal)
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "Clap_Unfilled"), for: .normal)
        }
        
        if model.isFan {
            rsvpButton.setImage(#imageLiteral(resourceName: "RSVP_Filled"), for: .normal)
        } else {
            rsvpButton.setImage(#imageLiteral(resourceName: "RSVP_Unfilled"), for: .normal)
        }
        
    if model.status == MatchStatus.upcomming {
        //upcoming
        self.bgView.backgroundColor = UIColor(hex: 0xfd9326)
    } else if model.status == MatchStatus.live {
        //live
        self.bgView.backgroundColor = UIColor(hex: 0x3bca9c)
        self.finalLabel.text = "LIVE NOW"
    } else {
        // final
        self.bgView.backgroundColor = UIColor(hex: 0xf56072)
        self.finalLabel.text = "FINAL"
    }

      self.homeScoreLabel.superview?.backgroundColor = self.bgView.backgroundColor

      self.likeButton.isSelected = model.isLiked
      self.rsvpButton.isSelected = model.isFan

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

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapGestureOnRSVPLabel))
    self.rsvpLabel.isUserInteractionEnabled = true
    self.rsvpLabel.addGestureRecognizer(tapGesture)
    
  }

    
    override func prepareForReuse() {
    super.prepareForReuse()

    self.finalLabel.isHidden = true
    self.homeScoreLabel.superview?.isHidden = true
  }

  @IBAction func rsvpTapped(_ sender: UIButton) {
    if self.rsvpButton.isSelected {
      let alert = UIAlertController(title: "Gameday", message: "Do you want to un-RSVP?", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
      let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (_) in
        self.delegate?.didPressedRSVPButton(cell: self)
        self.rsvpButton.setImage(#imageLiteral(resourceName: "RSVP_Unfilled"), for: .normal)
        let fansNumber = NSMutableAttributedString(string: "\(self.model.fansCount - 1)", attributes: self.attrs_black)
        let fans = NSMutableAttributedString(string:" Fans", attributes: self.attrs_gray)
        fansNumber.append(fans)
        self.rsvpLabel.attributedText = fansNumber
      }
      alert.addAction(yesAction)
      UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    } else {
        let banner = StatusBarNotificationBanner(title: "You are signed up for this game!", style: .success)
        banner.autoDismiss = false
        banner.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
           banner.dismiss()
        })
        self.rsvpButton.setImage(#imageLiteral(resourceName: "RSVP_Filled"), for: .normal)
        self.delegate?.didPressedRSVPButton(cell: self)
        let fansNumber = NSMutableAttributedString(string: "\(model.fansCount + 1)", attributes:attrs_black)
        let fans = NSMutableAttributedString(string:" Fans", attributes:attrs_gray)
        fansNumber.append(fans)
        self.rsvpLabel.attributedText = fansNumber
    }

    self.rsvpButton.isSelected = !self.rsvpButton.isSelected
  }

  @IBAction func likeTapped(_ sender: UIButton) {
    guard self.likeButton.isSelected == false else {
        let banner = StatusBarNotificationBanner(title: "You have already liked this game!", style: .warning)
        banner.autoDismiss = false
        banner.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            banner.dismiss()
        })
        return
    }
    likeButton.setImage(#imageLiteral(resourceName: "Clap_Filled"), for: .normal)
    
    self.delegate?.didPressedLikeButton(cell: self)
    let likeNumber = NSMutableAttributedString(string: "\(model.likesCount + 1)", attributes: attrs_black)
    let like = NSMutableAttributedString(string:" Likes", attributes: attrs_gray)
    likeNumber.append(like)
    self.likeButton.isSelected = true
    self.likeLabel.attributedText = likeNumber
  }

  @objc func didTapGestureOnRSVPLabel() {
    self.delegate?.didPressedRSVPLabel(cell: self)
  }

}
