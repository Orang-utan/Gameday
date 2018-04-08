//
//  MainTabBarViewController.swift
//  Gameday-V2
//
//  Created by Daniel on 4/7/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    let button = UIButton.init(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        button.setTitle("Add", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.setTitleColor(.gray , for: .highlighted)
//        button.backgroundColor = .white
        button.setImage(#imageLiteral(resourceName: "Add_TabBar"), for: .normal)
        //button.layer.cornerRadius = 32
        //button.layer.borderWidth = 4
        //button.layer.borderColor = UIColor(hex: 0x3bca9c).cgColor
        self.view.insertSubview(button, aboveSubview: self.tabBar)
        
        guard let tabItems = tabBar.items else { return }
        tabItems[0].titlePositionAdjustment = UIOffset(horizontal: -15, vertical: 0)
        tabItems[1].titlePositionAdjustment = UIOffset(horizontal: 15, vertical: 0)
        
        button.addTarget(self, action: #selector(addGameButtonTapped), for: UIControlEvents.touchUpInside)
    }
    
    @objc func addGameButtonTapped() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addGameTabBarTapped"), object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.frame = CGRect.init(x: self.tabBar.center.x - 32, y: self.view.bounds.height - 70, width: 64, height: 64)
        // safe place to set the frame of button manually
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                button.frame = CGRect.init(x: self.tabBar.center.x - 32, y: self.view.bounds.height - 100, width: 64, height: 64)
            default:
                print("unknown")
            }
        }
        
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
