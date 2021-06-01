//
//  MailboxRationReviewCell.swift
//  ProtonMail - Created on 3/10/16.
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
import MCSwipeTableViewCell

protocol MailboxRateReviewCellDelegate {
    func mailboxRateReviewCell(_ cell: UITableViewCell, yesORno: Bool)
}

class MailboxRateReviewCell : MCSwipeTableViewCell {
    /**
    *  Constants
    */
    struct Constant {
        static let identifier = "MailboxRateReviewCell"
    }
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    var callback: MailboxRateReviewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        noButton.layer.cornerRadius = 2
        noButton.layer.borderColor = UIColor(RRGGBB: UInt(0x9199CB)).cgColor
        noButton.layer.borderWidth = 1
        
        yesButton.layer.cornerRadius = 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    @IBAction func yesAction(_ sender: UIButton) {
        callback?.mailboxRateReviewCell(self, yesORno: true)
    }
    
    @IBAction func noAction(_ sender: UIButton) {
        callback?.mailboxRateReviewCell(self, yesORno: false)
    }
}
