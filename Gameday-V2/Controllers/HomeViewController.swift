//
//  ViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 3/31/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeSegmentControl: UISegmentedControl!
    
    var data: [SportsGame] = []
    
    let attrs_black = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : UIColor.black]
    

    let attrs_gray = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : UIColor.gray]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        timeSegmentControl.layer.cornerRadius = 0 
        observePosts()
    }
    
    func observePosts() {
        let postRef = Database.database().reference().child("gamePosts")
        
        postRef.observe(.value, with: { snapshot in
            var tempData = [SportsGame]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let photoURL = author["photoURL"] as? String,
                    let url = URL(string: photoURL),
                    let awayScore = dict["awayScore"] as? Int,
                    let awayTeam = dict["awayteam"] as? String,
                    let date = dict["date"] as? String,
                    let homeScore = dict["homeScore"] as? Int,
                    let homeTeam = dict["hometeam"] as? String,
                    let level = dict["level"] as? String,
                    let like = dict["like"] as? Int,
                    let place = dict["place"] as? String,
                    let rsvp = dict["rsvp"] as? [String:Any],
                    let sportsType = dict["sportsType"] as? String,
                    let time = dict["time"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    let userProfile = UserProfile(uid: uid, username: username, photoURL: url)
                    let game = SportsGame(id: childSnapshot.key, author: userProfile, sportsType: sportsType, sportsLevel: level, homeTeam: homeTeam, awayTeam: awayTeam, time: time, date: date, location: place, timestamp: timestamp)
                    game.homeScore = homeScore
                    game.awayScore = awayScore
                    game.like = like
                    
                    for (_, value) in rsvp {
                        if let dict = value as? [String: Any],
                        let username = dict["username"] as? String,
                        let uid = dict["uid"] as? String,
                        let photoURL = dict["photoURL"] as? String,
                            let url = URL(string: photoURL) {
                            let userProfile = UserProfile(uid: uid, username: username, photoURL: url)
                            game.rsvp.insert(userProfile, at: 0)
                        }
                    }
                    tempData.insert(game, at: 0)
                
                }
            }
            
            self.data = tempData
            self.tableView.reloadData()
        })
    }
    
    @IBAction func createGameTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "HomeToCreateSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameTableViewCell
        
        let game = data[indexPath.row]
        
        //by default, delete button is hidden
        cell.deleteButton.isHidden = true
        
        if let userProfile = UserService.currentUserProfile {
            if game.author.uid == userProfile.uid {
                cell.deleteButton.isHidden = false
            }
        }
        ImageService.getImage(withURL: game.author.photoURL) {
            image in
            cell.userProfile.image = image
        }
        
        cell.userName.text = game.author.username
        
        cell.homeTeamLabel.text = game.homeTeam
        cell.homeTeamPicture.image = game.getTeamImage(team: "\(game.homeTeam)")
        
        cell.awayTeamLabel.text = game.awayTeam
        cell.awayTeamPicture.image = game.getTeamImage(team: "\(game.awayTeam)")
        
        cell.gameTitleLabel.text = game.getGameTitle()
        
        cell.gameTimeLabel.text = game.getTime()
        cell.dateAndLocationLabel.text = ("\(game.getDate()) @ \(game.location!)")
        
        let likeNumber = NSMutableAttributedString(string: "\(game.like)", attributes:attrs_black)
        let like = (NSMutableAttributedString(string:" Likes", attributes:attrs_gray))
        likeNumber.append(like)
        cell.likeLabel.attributedText = likeNumber
    
        let fansNumber = NSMutableAttributedString(string: "\(game.rsvp.count)", attributes:attrs_black)
        let fans = (NSMutableAttributedString(string:" Fans", attributes:attrs_gray))
        fansNumber.append(fans)
        cell.rsvpLabel.attributedText = fansNumber
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "HomeToDetailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 265
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

}

