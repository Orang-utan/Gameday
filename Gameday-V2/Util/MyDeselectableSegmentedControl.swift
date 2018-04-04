//
//  MyDeselectableSegmentedControl.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 4/4/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit

class MyDeselectableSegmentedControl: UISegmentedControl {
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let previousIndex = selectedSegmentIndex

    super.touchesEnded(touches, with: event)

    if previousIndex == selectedSegmentIndex {
      let touchLocation = touches.first!.location(in: self)

      if bounds.contains(touchLocation) {
        self.selectedSegmentIndex = UISegmentedControlNoSegment
        sendActions(for: .valueChanged)
      }
    }
  }
}
