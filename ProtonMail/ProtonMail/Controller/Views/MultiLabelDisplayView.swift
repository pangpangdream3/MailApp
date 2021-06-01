//
//  MultiLabelDisplayView.swift
//  ProtonMail - Created on 9/9/15.
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

class MultiLabelDisplayView: PMView {
    
    var labels : [Label]?
    
    @IBOutlet var label1: LabelDisplayView!
    
    
    
    var labelOne: LabelDisplayView!
    
    override func getNibName() -> String {
        return "MultiLabelDisplayView";
    }
    
    override func setup() {
        labelOne = LabelDisplayView()
        self.pmView.addSubview(labelOne)
        
        
        label1.mas_updateConstraints { (make) -> Void in
            make?.removeExisting = true
            let _ = make?.right.equalTo()(self.pmView.mas_left)
            let _ = make?.bottom.equalTo()(self.pmView.mas_bottom)
            let _ = make?.top.equalTo()(self.pmView.mas_top)
        }
    }
    
    func updateLablesDetails(_ labelView: LabelDisplayView, label: Label?) {
        if let label = label {
            if label.name.isEmpty || label.color.isEmpty {
                //labelView.hidden = true;
            } else {
                //labelView.hidden = false;
                labelView.labelTitle = label.name
                labelView.LabelTintColor = UIColor(hexString: label.color, alpha: 1.0)
            }
        } else {
            //labelView.hidden = true;
        }

    }
    
    
}


