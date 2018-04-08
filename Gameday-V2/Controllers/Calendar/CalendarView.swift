//
//  CalendarViewController.swift
//  Gameday-V2
//
//  Created by Tuan Nguyen on 4/8/18.
//  Copyright © 2018 Daniel Tian. All rights reserved.
//

import UIKit
import JTAppleCalendar
import RxCocoa
import DateToolsSwift

protocol CalendarViewDelegate: class {
  func didSelectedDate(date: Date)
}

final class CalendarView: UIView {

  @IBOutlet weak var calendarView: JTAppleCalendarView!
  @IBOutlet weak var currentMonthAndYearLabel: UILabel!

  let formatter = DateFormatter()
  var selectDate: Date? {
    didSet {
      if let selectDate = self.selectDate {
        self.calendarView.scrollToDate(selectDate, animateScroll: false)
        self.calendarView.selectDates([selectDate])
      } else {
        self.calendarView.scrollToDate(Date(), animateScroll: false)
      }
    }
  }
  weak var delegate: CalendarViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.commonInit()
    self.setupCalendarView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.commonInit()
  }

  private func commonInit() {
    let view = Bundle.main.loadNibNamed("CalendarView", owner: self, options: nil)![0] as! UIView
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.addSubview(view)
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    self.setupCalendarView()
  }

  func setupCalendarView() {
    self.calendarView.register(UINib.init(nibName: "CalendarCell", bundle: nil), forCellWithReuseIdentifier: "CalendarCell")
    self.calendarView.minimumLineSpacing = 0
    self.calendarView.minimumInteritemSpacing = 0

    self.calendarView.visibleDates { [unowned self] in
      self.setupTitle(visibleDates: $0)
    }
  }

  func setupTitle(visibleDates: DateSegmentInfo) {
    guard let date = visibleDates.monthDates.first?.date else {
      return
    }
    self.formatter.dateFormat = "MMMM yyyy"
    self.currentMonthAndYearLabel.text = self.formatter.string(from: date)
  }

  func configureVisibleCell(myCustomCell: CalendarCell, cellState: CellState, date: Date) {
    myCustomCell.dateLabel.text = cellState.text
    if date.isToday {
      myCustomCell.contentView.backgroundColor = UIColor(hex: 0xE9E9E9)
    } else {
      myCustomCell.contentView.backgroundColor = UIColor.white
    }

    handleCellConfiguration(cell: myCustomCell, cellState: cellState)
  }

  func handleCellConfiguration(cell: JTAppleCell?, cellState: CellState) {
    handleCellSelection(view: cell, cellState: cellState)
    handleCellTextColor(view: cell, cellState: cellState)
  }

  // Function to handle the text color of the calendar
  func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
    guard let myCustomCell = view as? CalendarCell  else { return }

    if cellState.isSelected {
      myCustomCell.dateLabel.textColor = UIColor.black
    } else {
      if cellState.dateBelongsTo == .thisMonth {
        myCustomCell.dateLabel.textColor = UIColor.black
      } else {
        myCustomCell.dateLabel.textColor = UIColor(hex: 0xF9F9F9)
        myCustomCell.contentView.backgroundColor = UIColor(hex: 0xF9F9F9)
      }
    }
  }

  // Function to handle the calendar selection
  func handleCellSelection(view: JTAppleCell?, cellState: CellState) {
    guard let myCustomCell = view as? CalendarCell else {return }
    //        switch cellState.selectedPosition() {
    //        case .full:
    //            myCustomCell.backgroundColor = .green
    //        case .left:
    //            myCustomCell.backgroundColor = .yellow
    //        case .right:
    //            myCustomCell.backgroundColor = .red
    //        case .middle:
    //            myCustomCell.backgroundColor = .blue
    //        case .none:
    //            myCustomCell.backgroundColor = nil
    //        }
    //
    if cellState.isSelected {
      myCustomCell.contentView.backgroundColor = UIColor.green
    } else {
      myCustomCell.contentView.backgroundColor = cellState.date.isToday ? UIColor(hex: 0xE9E9E9) : UIColor.white
    }
  }
}

extension CalendarView: JTAppleCalendarViewDataSource {
  func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    self.formatter.dateFormat = "dd/MM/yyyy"
    let startDate = self.formatter.date(from: "01/01/2015") ?? Date()
    let endDate = self.formatter.date(from: "31/12/2020") ?? Date()
    let params = ConfigurationParameters(startDate: startDate,
                                         endDate: endDate)
    return params
  }
}

extension CalendarView: JTAppleCalendarViewDelegate {
  func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    let cell = cell as! CalendarCell
    configureVisibleCell(myCustomCell: cell, cellState: cellState, date: date)
  }

  func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
    configureVisibleCell(myCustomCell: cell, cellState: cellState, date: date)
    return cell
  }

  func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    self.setupTitle(visibleDates: visibleDates)
  }

  func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
    return cellState.dateBelongsTo == .thisMonth
  }

  func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    handleCellConfiguration(cell: cell, cellState: cellState)
    self.delegate?.didSelectedDate(date: date)
  }

  func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    handleCellConfiguration(cell: cell, cellState: cellState)
  }
}
