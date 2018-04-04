//
//  CreateGameViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 3/31/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import SwiftyPickerPopover
import Firebase

class CreateGameViewController: UIViewController, UITextFieldDelegate {

  //https://github.com/apasccon/SearchTextField

  @IBOutlet weak var homeTextField: SearchTextField!
  @IBOutlet weak var awayTextField: SearchTextField!
  @IBOutlet weak var sportsTextField: SearchTextField!
  @IBOutlet weak var levelTextField: SearchTextField!
  @IBOutlet weak var dateTextField: SearchTextField!
  @IBOutlet weak var timeTextField: SearchTextField!
  @IBOutlet weak var locationTextField: SearchTextField!
  @IBOutlet weak var checkBox: Checkbox!
  @IBOutlet weak var saveGame: UIButton!

  let sportsChoices = ["Baseball", "Crew", "Lacrosse","Softball", "Track and Field"]
  let schoolFilters: [String] = ["Berkshire", "Taft", "Hotchkiss", "Salisbury"]

  var selectedSportsString = ""
  var selectedSportsRow = 0

  var selectedLevelString = ""
  var selectedLevelRows = [0, 0]

  var selectedDateString = ""

  var selectedTimeString = ""

  override func viewDidLoad() {
    super.viewDidLoad()

    homeTextField.borderStyle = UITextBorderStyle.roundedRect
    awayTextField.borderStyle = UITextBorderStyle.roundedRect

    homeTextField.filterStrings(schoolFilters)
    awayTextField.filterStrings(schoolFilters)

    homeTextField.theme.font = UIFont.systemFont(ofSize: 16)
    homeTextField.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    homeTextField.theme.borderColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    homeTextField.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
    homeTextField.theme.cellHeight = 50

    awayTextField.theme.font = UIFont.systemFont(ofSize: 16)
    awayTextField.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    awayTextField.theme.borderColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    awayTextField.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
    awayTextField.theme.cellHeight = 50

    sportsTextField.borderStyle = UITextBorderStyle.roundedRect
    levelTextField.borderStyle = UITextBorderStyle.roundedRect

    dateTextField.borderStyle = UITextBorderStyle.roundedRect
    timeTextField.borderStyle = UITextBorderStyle.roundedRect

    locationTextField.borderStyle = UITextBorderStyle.roundedRect

    sportsTextField.delegate = self
    levelTextField.delegate = self

    dateTextField.delegate = self
    timeTextField.delegate = self

    checkBox.checkmarkStyle = .square
    checkBox.checkmarkStyle = .tick
    checkBox.layer.masksToBounds = true
    checkBox.layer.cornerRadius = 5

    saveGame.layer.cornerRadius = 5

    selectedSportsRow = Int(sportsChoices.count/2)

    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == sportsTextField || textField == levelTextField || textField == timeTextField || textField == dateTextField {
      return false
    }
    return true
  }

  @IBAction func sportsTextFieldTapped(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
    StringPickerPopover(title: "Game Type", choices: sportsChoices)
      .setSelectedRow(selectedSportsRow)
      .setDoneButton(action: { (popover, selectedRow, selectedString) in
        self.selectedSportsString = selectedString
        self.selectedSportsRow = selectedRow
        self.sportsTextField.text = self.selectedSportsString
      })
      .setCancelButton(action: { (_, _, _) in print("cancel")}
      )
      .appear(originView: sportsTextField, baseViewController: self)
  }

  @IBAction func levelTextFieldTapped(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
    ColumnStringPickerPopover(title: "Game Level",
                              choices: [["Boys", "Girls"],["Varsity", "JV", "Thirds"]],
                              selectedRows: selectedLevelRows, columnPercents: [0.5, 0.5])
      .setDoneButton(action: { popover, selectedRows, selectedStrings in
        self.selectedLevelRows = selectedRows
        self.selectedLevelString = "\(selectedStrings[0]) \(selectedStrings[1])"
        self.levelTextField.text = self.selectedLevelString

      })
      .setCancelButton(action: {_, _, _ in print("cancel")})
      .setFontSizes([18])
      .appear(originView: levelTextField, baseViewController: self)
    
  }

  @IBAction func dateTextFieldTapped(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
    DatePickerPopover(title: "Game Date")
      .setDateMode(.date)
      .setSelectedDate(Date())
      .setDoneButton(action: { popover, selectedDate in
        var dateArr1 = "\(selectedDate)".components(separatedBy: " ")
        self.selectedDateString = "\(dateArr1[0]) \(dateArr1[1])"
        print(self.selectedDateString)
        let local = UTCToLocal(date: self.selectedDateString)
        let dateArr2 = "\(local)".components(separatedBy: " ")
        self.dateTextField.text = formatDateStr(date: dateArr2[0])
      })
      .setCancelButton(action: { _, _ in print("cancel")})
      .appear(originView: dateTextField, baseViewController: self)
  }

  @IBAction func timeTextFieldTapped(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
    DatePickerPopover(title: "Game Time")
      .setDateMode(.time)
      .setMinuteInterval(1)
      .setDoneButton(action: { popover, selectedDate in
        var dateArr1 = "\(selectedDate)".components(separatedBy: " ")
        self.selectedTimeString = "\(dateArr1[0]) \(dateArr1[1])"
        print(self.selectedTimeString)
        let local = UTCToLocal(date: self.selectedTimeString)
        print(local)
        let dateArr2 = "\(local)".components(separatedBy: " ")
        print(dateArr2)
        self.timeTextField.text = dateArr2[1]
        print(dateArr2[1])
      } )
      .setCancelButton(action: { _, _ in print("cancel")})
      .appear(originView: timeTextField, baseViewController: self)
  }

  @IBAction func bgViewTapped(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }

  @IBAction func saveGameTapped(_ sender: UIButton) {
    if let homeTeam = homeTextField.text, let awayTeam = awayTextField.text, let place = locationTextField.text {
      //check if any of the fields are empty
      if homeTeam == "" || awayTeam == "" || place == "" || selectedSportsString == "" || selectedLevelString == "" || selectedTimeString == "" || selectedDateString == "" {
        return
      }
      //check if box is checked
      if !checkBox.isChecked {
        let alert = UIAlertController(title: "Wait a second!", message: "Please make sure the information you provided is accurate by checking the box.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
          action in
          return
        }))
        self.present(alert, animated: true, completion: nil)
        return
      }

      //process data here!
      guard let userProfile = UserService.currentUserProfile else {
        print("failed")
        return
      }

      let postRef = Database.database().reference().child("gamePosts").childByAutoId()

      let postObject = [
        "author": [
          "uid": userProfile.uid,
          "username": userProfile.username,
          "photoURL": userProfile.photoURL.absoluteString
        ],
        "hometeam": homeTeam.capitalized,
        "awayteam": awayTeam.capitalized,
        "homeScore": 0,
        "awayScore": 0,
        "place": place,
        "sportsType": selectedSportsString,
        "level": selectedLevelString,
        "time": selectedTimeString,
        "date": selectedDateString,
        "like": 0,
        "rsvp": [
          "\(userProfile.uid)": [
            "username": userProfile.username,
            "uid": userProfile.uid,
            "photoURL": userProfile.photoURL.absoluteString
          ]
        ],
        "timestamp": [".sv": "timestamp"]
        ] as [String:Any]

      postRef.setValue(postObject, withCompletionBlock: { error, ref in
        if error == nil {
          self.dismiss(animated: true, completion: nil)
        } else {
          //handle error here
        }
      })
    }
  }

  @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}
