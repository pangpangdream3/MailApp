//
//  ContactSearchTableViewController.swift
//  ProtonMail - Created on 19/07/2018.
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

class ContactSearchTableViewController: UITableViewController {
    internal var queryString = ""
    internal var onSelection: ((ContactPickerModelProtocol)->Void) = { _ in }
    internal var filteredContacts: [ContactPickerModelProtocol] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let outCell = tableView.dequeueReusableCell(withIdentifier: ContactPickerDefined.ContactsTableViewCellIdentifier,
                                                         for: indexPath)
        if indexPath.row < self.filteredContacts.count, let cell = outCell as? ContactsTableViewCell {
            let model = self.filteredContacts[indexPath.row]
            cell.config(name: model.contactTitle,
                        email: model.contactSubtitle ?? "",
                        highlight: queryString,
                        color: model.color)
        }
        return outCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.filteredContacts[indexPath.row]
        self.onSelection(model)
    }
    
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return UIDevice.current.orientation == .landscapeLeft ||
                UIDevice.current.orientation == .landscapeRight
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
