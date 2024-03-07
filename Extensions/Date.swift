//
//  Date.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation

extension Date{
    
    func toString() -> String{
        if self.timeIntervalSinceNow > -60*60*24{
            let h = String(Date.get(.hour)).setw("0", 2)
            let m = String(Date.get(.minute)).setw("0", 2)
            return "\(h):\(m)"
        }
        return "\(Date.get(.day))/\(Date.get(.month))/\(Date.get(.year))"
    }
    
    func get() -> String{
        var str = ""
        for type in [dateType.year,dateType.month,dateType.day,dateType.hour,dateType.minute,dateType.second]{
            str += "\(Date.get(type)):"
        }
        str.removeLast()
        return str
    }
    
    static func getDayOfWeek() -> String {
        let today = Date().get()
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd:HH:mm:ss"
        guard let todayDate = formatter.date(from: today) else {
            return ""
        }
        let myCalendar = Calendar(identifier: .gregorian)
        var weekDay = myCalendar.component(.weekday, from: todayDate)-2
        
        while weekDay < 0{
            weekDay += 7
        }
        while weekDay >= 7{
            weekDay -= 7
        }
        
        return weekdays[weekDay]
    }
    
    static func tomorrow() -> String{
        let i = Date.weekdays.firstIndex(of: Date.getDayOfWeek())!
        if i == 6{
            return "monday"
        }
        else{
            return Date.weekdays[i+1]
        }
    }
    
    static func time() -> String{
        return "\(Date.get(.hour)):\(Date.get(.minute))"
    }
    
    static let weekdays = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
    
    static  func get(_ type: dateType) -> Int{
        let formatter = DateFormatter()
        switch type {
            case .second:
            formatter.dateFormat = "ss"
                break
            case .minute:
            formatter.dateFormat = "mm"
                break
            case .hour:
            formatter.dateFormat = "HH"
                break
            case .day:
            formatter.dateFormat = "dd"
                break
            case .month:
            formatter.dateFormat = "MM"
                break
            case .year:
            formatter.dateFormat = "yyyy"
                break
        }
        return Int(formatter.string(from: Date.init()))!
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var twoDaysAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: noon)!
    }
    var threeDaysAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: noon)!
    }
    var fourDaysAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var twoHoursAgo: Date {
        return Calendar.current.date(byAdding: .hour, value: -2, to: noon)!
    }
    var fiveHoursAgo: Date {
        return Calendar.current.date(byAdding: .hour, value: -5, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var oneYearAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -12, to: noon)!
    }
    var oneWeekAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: noon)!
    }
    var oneMonthAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: noon)!
    }
    var threeMonthsAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -3, to: noon)!
    }
    var infiniteAgo: Date {
        return Calendar.current.date(byAdding: .year, value: 100, to: noon)!
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    
}

enum dateType{
    case day
    case month
    case year
    case second
    case minute
    case hour
}
