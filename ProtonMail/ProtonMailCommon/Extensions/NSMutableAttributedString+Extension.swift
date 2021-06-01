//
//  NSMutableAttributedString+Extension.swift
//  ProtonMail - Created on 2018/10/22.
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.


import Foundation

extension NSAttributedString {
    /**
     - parameters:
     - text: original string
     - search: search term to be highlighted in the string
     */
    class func highlightedString(text: String,
                                 search: String,
                                 font: UIFont) -> NSAttributedString {
        let resultText = text
        let searchTerm = search
        let attributedString = NSMutableAttributedString(string: resultText)
        let pattern = "(\(searchTerm))"
        let range = NSMakeRange(0, resultText.count)
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        regex.enumerateMatches(
            in: resultText,
            options: NSRegularExpression.MatchingOptions(),
            range: range,
            using: { (textCheckingResult, matchingFlags, stop) -> Void in
                let subRange = textCheckingResult?.range
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                              value: UIColor.ProtonMail.Blue_6789AB,
                                              range: subRange!)
                
                attributedString.addAttribute(NSAttributedString.Key.font,
                                              value: font,
                                              range: subRange!)
        })
        
        return attributedString
    }
}
