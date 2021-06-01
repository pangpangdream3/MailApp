//
//  ContactEditTextViewCell.swift
//  ProtonMail - Created on 12/28/17.
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

protocol ContactEditTextViewCellDelegate {
    func beginEditing(textView: UITextView)
    func didChanged(textView: UITextView)
    func featureBlocked(textView: UITextView)
}

final class ContactEditTextViewCell: UITableViewCell {
    
    fileprivate var note : ContactEditNote!
    fileprivate var delegate : ContactEditTextViewCellDelegate?
    
    @IBOutlet weak var textView: UITextView!
    
    fileprivate var isPaid : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.delegate = self
    }
    @IBAction func notesClicked(_ sender: Any) {
        
        self.textView.becomeFirstResponder()
    }
    
    func configCell(obj : ContactEditNote, paid: Bool, callback : ContactEditTextViewCellDelegate?) {
        self.note = obj
        self.isPaid = paid
        self.delegate = callback
        
        self.textView.text = self.note.newNote
        self.textView.sizeToFit()
        self.delegate?.didChanged(textView: textView)
    }
}

extension ContactEditTextViewCell: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard self.isPaid else {
            self.delegate?.featureBlocked(textView: textView)
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.beginEditing(textView: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard self.isPaid else {
            self.delegate?.featureBlocked(textView: textView)
            return
        }
        if let text = textView.text, text != note.newNote {
            note.newNote = text
            self.delegate?.didChanged(textView: textView)
        }
    }
}
