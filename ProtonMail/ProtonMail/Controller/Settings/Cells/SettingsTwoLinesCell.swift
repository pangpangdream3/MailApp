//
//  SettingsTwoLinesCell.swift
//  ProtonMail - Created on 3/17/15.
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


import UIKit

@IBDesignable class SettingsTwoLinesCell: UITableViewCell, AccessibleCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var CellID : String  {
        return "\(self)"
    }
    
    @IBOutlet weak var topLineLabel: UILabel!
    @IBOutlet weak var bottomLineLabel: UILabel!
    
    func config(top tValue: String, bottom bValue: String) {
        self.topLineLabel.text = tValue
        self.bottomLineLabel.text = bValue
        generateCellAccessibilityIdentifiers(bValue)
    }
}

extension SettingsTwoLinesCell: IBDesignableLabeled {
    override func prepareForInterfaceBuilder() {
        self.labelAtInterfaceBuilder()
    }
}
