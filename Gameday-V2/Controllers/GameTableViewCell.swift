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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfile.layer.cornerRadius = userProfile.bounds.height / 2
        userProfile.clipsToBounds = true
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
