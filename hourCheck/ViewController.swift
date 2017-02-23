//
//  ViewController.swift
//  hourCheck
//
//  Created by Abhijeet Mishra on 22/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit

struct DateContainer {
    var date:Date!
    var enabled:Bool!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startTimeSlider: UISlider!
    @IBOutlet weak var endTimeSlider: UISlider!
    @IBOutlet weak var dayStartLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dayEndLabel: UILabel!
    
   var dateArray = [Date]()
    
   var dateComponents:DateComponents {
        let date = Date.init()
        let calendar = Calendar.init(identifier: .gregorian)
        let dateComponents = calendar.dateComponents(in: .current, from: date)
        return dateComponents
    }
    
    var noOfAMHours:Int {
        return (12 - currentStartHour)
    }
    
    var noOfPMHours:Int {
        return currentStopHour
    }
    
    var noOfRemainingHours: Int? {
        didSet {
         tableView.reloadData()
        }
    }
    
    var currentStartHour: Int {
        return Int(startTimeSlider.value)/1
    }
   
    var currentStopHour: Int {
        return Int(endTimeSlider.value)/1
    }
    
    func createAllDateObjects ()  {
        
        var iterator = noOfRemainingHours
        iterator = iterator! - 1
        
        dateArray = [Date]()
        
        while iterator! > 0 {
            let date = getDateObject(indexPathRow: iterator)
            dateArray.append(date)
            iterator = iterator! - 1
        }
    }
    
    func scheduleReminders()  {
      
        createAllDateObjects()
        
        //remove all previous notifications
        (UIApplication.shared.delegate as! AppDelegate).removeAllLocalNotifications()
        
        var iterator = 1
        
        for date in dateArray {
          //  let delay =  DispatchTimeInterval.milliseconds(iterator * 1000) //iterator * 2.0
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                (UIApplication.shared.delegate as! AppDelegate).scheduleNotification(at: date, message: self.textView.text!)
            })
            iterator = iterator + 1
        }
    }
    
    override func viewDidLoad() {
        calculateRemainingHours()
        scheduleReminders()
    }
    @IBAction func startTimeValueChanged(_ sender: UISlider) {
        activeRemainingHours()
    }
    @IBAction func endTimeValueChanged(_ sender: UISlider) {
        activeRemainingHours()
    }
    
    @IBAction func startTimeChanged(_ sender: UISlider) {
        scheduleReminders()
    }
    
    @IBAction func endTimeChanged(_ sender: UISlider) {
        scheduleReminders()
    }
    
    
    @IBAction func startPressed(_ sender: UIButton) {
//        let selectedDate = Date.init(timeIntervalSinceNow: 60)
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        delegate.scheduleNotification(at: selectedDate, message:textView.text)
    }
    
    func calculateRemainingHours()  {
        let currentDate = Date.init()
        let calendar = Calendar.init(identifier: .gregorian)
        let dateComponents = calendar.dateComponents(in: .current, from: currentDate)
        let hour = dateComponents.hour
        
        noOfRemainingHours = 24 - hour!
        
        activeRemainingHours()
    }
    
    
    func updateStartTimeText() {
        switch currentStartHour {
        case 0:
            dayStartLabel.text = "12:00 AM"
            break
            
        case 10:
            dayStartLabel.text = "10:00 AM"
            break
        case 12:
            dayStartLabel.text = "12:00 PM"
            break
            
        default:
            dayStartLabel.text = currentStartHour % 10 == 0 ? String("0" + String(currentStartHour) + ":00 AM") : String(String(currentStartHour) + ":00 AM")
        }
    }
   
    func updateStopTimeText() {
        switch currentStopHour {
        case 0:
            dayEndLabel.text = "12:00 PM"
            break
            
        case 10:
            dayEndLabel.text = "10:00 PM"
            break
        case 12:
            dayEndLabel.text = "12:00 AM"
            break
            
        default:
            dayEndLabel.text = currentStopHour % 10 == 0 ? String("0" + String(currentStopHour) + ":00 PM") : String(String(currentStopHour) + ":00 PM")
        }
    }
    func activeRemainingHours()  {
       updateStartTimeText()
       updateStopTimeText()
       
        noOfRemainingHours = noOfAMHours + noOfPMHours
    }
    
    func isAMHour(indexPathRow:Int) -> Bool {
        return indexPathRow < noOfAMHours
    }
    
    func amHour(indexPathRow:Int) -> String {
        if isAMHour(indexPathRow: indexPathRow) {
            if currentStartHour == 0 && indexPathRow == 0 {
                return "12:00 AM"
            }
            let currentAMDisplay = currentStartHour + indexPathRow
            
            if currentAMDisplay % 10 == 0 && currentAMDisplay != 10 {
              return "0" + String(currentAMDisplay) + ":00 AM"
            }
            else if currentAMDisplay == 10 {
                return "10:00 AM"
            }
            else {
                return String(currentAMDisplay) + ":00 AM"
            }
        }
        return String("Invalid AM Hour")
    }
   
    func amHourIntValue(indexPathRow:Int) -> Int {
        if isAMHour(indexPathRow: indexPathRow) {
            if currentStartHour == 0 && indexPathRow == 0 {
                return 0
            }
            let currentAMDisplay = currentStartHour + indexPathRow
            
            if currentAMDisplay % 10 == 0 && currentAMDisplay != 10 {
                return currentAMDisplay
            }
            else if currentAMDisplay == 10 {
                return 10
            }
            else {
                return currentAMDisplay
            }
        }
        return 0
    }
    func pmHour(indexPathRow:Int) -> String {
        if !isAMHour(indexPathRow: indexPathRow) {
            if indexPathRow == noOfAMHours {
                return String("12:00 PM")
            }
            
            let currentDisplayPMDisplay = indexPathRow - noOfAMHours
            
            if currentDisplayPMDisplay % 10 == 0 && currentDisplayPMDisplay != 10{
                return "0" + String(currentDisplayPMDisplay) + ":00 PM"
            }
            else if currentDisplayPMDisplay == 10 {
                return "10:00 PM"
            }
            else {
             return String(currentDisplayPMDisplay) + ":00 PM"
            }
        }
        return String("Invalid PM Hour")
    }
    
    func pmHourIntValue (indexPathRow:Int) -> Int {
        if !isAMHour(indexPathRow: indexPathRow) {
            if indexPathRow == noOfAMHours {
                return 12
            }
            
            let currentDisplayPMDisplay = indexPathRow - noOfAMHours + 12
            
            if currentDisplayPMDisplay % 10 == 0 && currentDisplayPMDisplay != 10{
                return currentDisplayPMDisplay
            }
            else if currentDisplayPMDisplay == 10 {
                return 22            }
            else {
                return currentDisplayPMDisplay
            }
        }
        return 12
    }
    
    func getDateObject(indexPathRow:Int? ) -> Date {
        let newComponents = DateComponents.init(calendar: dateComponents.calendar, timeZone: dateComponents.timeZone, era: dateComponents.era, year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: isAMHour(indexPathRow: indexPathRow!) ? amHourIntValue(indexPathRow: indexPathRow!) : pmHourIntValue(indexPathRow: indexPathRow!) , minute: 0, second: 0, nanosecond: 0, weekday: dateComponents.weekday, weekdayOrdinal: dateComponents.weekdayOrdinal, quarter: dateComponents.quarter, weekOfMonth: dateComponents.weekOfMonth, weekOfYear: dateComponents.weekOfYear, yearForWeekOfYear: dateComponents.yearForWeekOfYear)
        
        let calendar = Calendar.init(identifier: .gregorian)
        let date = calendar.date(from: newComponents)
        return date!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isAM = isAMHour(indexPathRow: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ReminderTableViewCell
        cell.accessoryType = .checkmark
        cell.textLabel?.text = isAM ? amHour(indexPathRow: indexPath.row) : pmHour(indexPathRow: indexPath.row)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.date = getDateObject(indexPathRow: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noOfRemainingHours!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.none {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else  {
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
         scheduleReminders()
    }
}

