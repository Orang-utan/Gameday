//
//  CalendarCell.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 4/8/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import JTAppleCalendar

final class CalendarCell: JTAppleCell {
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var circleView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.contentView.layer.borderColor = UIColor(hex: 0xB9B9B9).cgColor
    self.contentView.layer.borderWidth = 0.5
  }
}
