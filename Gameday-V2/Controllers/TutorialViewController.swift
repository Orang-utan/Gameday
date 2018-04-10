//
//  TutorialViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 4/8/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.layer.cornerRadius = 25
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        UIApplication.shared.delegate?.window??.rootViewController = controller
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
