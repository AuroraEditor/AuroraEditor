//
//  Date.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 20.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import Foundation

public extension Date {

    /// Returns a formatted & localized string of a relative duration compared to the current date & time
    /// when the date is in `today` or `yesterday`. Otherwise it returns a formatted date in `short`
    /// format. The time is omitted.
    /// - Parameter locale: The locale. Defaults to `Locale.current`
    /// - Returns: A localized formatted string
    func relativeStringToNow(locale: Locale = .current) -> String {
        if Calendar.current.isDateInToday(self) ||
            Calendar.current.isDateInYesterday(self) {
            var style = RelativeFormatStyle(
                presentation: .named,
                unitsStyle: .abbreviated,
                locale: .current,
                calendar: .current,
                capitalizationContext: .standalone
            )

            style.locale = locale

            return self.formatted(style)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = locale

        return formatter.string(from: self)
    }

    /// Year month day format
    /// - Returns: date in yyyy-MM-dd
    func yearMonthDayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    /// GIT date format
    /// - Returns: date in E MMM dd HH:mm:ss yyyy Z
    func gitDateFormat(commitDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "E MMM dd HH:mm:ss yyyy Z"
        return dateFormatter.date(from: commitDate)
    }
}
