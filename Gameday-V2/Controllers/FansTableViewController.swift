//
//  FansTableViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 4/6/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD
import Nuke

class FanTableViewCell: UITableViewCell {
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!

}

class FansTableViewController: UITableViewController {

  private var fansData: [UserModel] = []
  var game: GamePostModel!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.tableFooterView = UIView()

    SVProgressHUD.show()
    let obs = game.fanUsersId.map { $0.key }.map { db.collection("users").document($0).rx.getDocument().asObservable() }
    Observable.zip(obs).asSingle()
      .mapArray(type: UserModel.self)
      .subscribe(onSuccess: { [weak self] (users) in
        SVProgressHUD.dismiss()
        self?.fansData = users
        self?.tableView.reloadData()
      }) { (error) in
        SVProgressHUD.showError(withStatus: error.localizedDescription)
      }.disposed(by: rx.disposeBag)
  }

  @IBAction func backButtonPressed(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.fansData.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FanTableViewCell
    if let urlString = self.fansData[indexPath.row].photoURL, let url = URL(string: urlString) {
      Nuke.Manager.shared.loadImage(with: url, into: cell.profileImageView)
    }
    cell.nameLabel.text = self.fansData[indexPath.row].displayName

    return cell
  }

  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */

  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */

  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

   }
   */

  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}
