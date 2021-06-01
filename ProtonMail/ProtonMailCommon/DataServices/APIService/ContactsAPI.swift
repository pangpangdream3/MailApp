//
//  ContactsAPI.swift
//  ProtonMail
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
import PMCommon


//Contact API
//Doc:https://github.com/ProtonMail/Slim-API/blob/develop/api-spec/pm_api_contacts_v2.md
struct ContactsAPI {
    
    static let path : String = "/contacts"
    
    /// get contact list. no details. only name, email, labels for displaying
    static let v_get_contacts : Int = 3
    /// get contact email list. this is for auto complete. combine with contacts would be full information without encrypted data.
    static let v_get_contact_emails : Int = 3
    /// add & import contact post
    static let v_add_contacts : Int = 3
    /// get contact details full date clear&encrypt data
    static let v_get_details : Int = 3
    /// update contact put
    static let v_update_contact : Int = 3
    /// delete contact put
    static let v_delete_contacts : Int = 3
    
    /// group
    /// label an array of emails to a certain contact group
    static let v_label_an_array_of_contact_emails: Int = 3
    
    /// unlabel an array of emails from a certain contact group
    static let v_unlabel_an_array_of_contact_emails: Int = 3
    
    /// export
    
    /// clear contacts
}

// MARK : Get contacts part -- ContactsResponse
class ContactsRequest : Request {
    var page : Int = 0
    var max : Int = 100
    
    init(page: Int, pageSize : Int) {
        self.page = page
        self.max = pageSize
    }
    
    var path : String {
        return ContactsAPI.path
    }
}

//
class ContactsResponse : Response {
    var total : Int = -1
    var contacts : [[String : Any]] = []
    override func ParseResponse (_ response: [String : Any]!) -> Bool {
        //PMLog.D("[Contact] Get contacts response \(response)")
        self.total = response?["Total"] as? Int ?? -1
        self.contacts = response?["Contacts"] as? [[String : Any]] ?? []
        return true
    }
}

// MARK : Get messages part
class ContactEmailsRequest : Request {  //ContactEmailsResponse
    var page : Int = 0
    var max : Int = 100
    let labelID: String?
    
    init(page: Int, pageSize : Int, labelID: String? = nil) {
        self.page = page
        self.max = pageSize
        self.labelID = labelID
    }
    
    var path: String {
        return ContactsAPI.path + "/emails"
    }
    
    var parameters: [String : Any]? {
        if let ID = labelID {
            return ["Page": page, "PageSize": max, "LabelID": ID]
        }
        return ["Page" : page, "PageSize" : max]
    }
}

// TODO: performance enhancement?
class ContactEmailsResponse: Response {
    var total : Int = -1
    var contacts : [[String : Any]] = [] // [["ID": ..., "Name": ..., "ContactEmails": ...], ...]
    override func ParseResponse (_ response: [String : Any]!) -> Bool {
        //PMLog.D("[Contact] Get contact emails response \(response)")
        self.total = response?["Total"] as? Int ?? -1
        if let tempContactEmails = response?["ContactEmails"] as? [[String : Any]] {
            // setup emails
            for var email in tempContactEmails { // for every email in ContactEmails
                if let contactID = email["ContactID"] as? String, let name = email["Name"] as? String {
                    // convert the labelID strings into JSON dictionary
                    if let labelIDs = email["LabelIDs"] as? [String] {
                        let mapping: [[String: Any]] = labelIDs.map({
                            (labelID: String) -> [String: Any] in
                            
                            // TODO: check if this will clear other fields or noang
                            return [
                                "ID": labelID,
                                "Type": 2 /* don't forget about it... */
                            ]
                        })
                        
                        email["LabelIDs"] = mapping
                    }
                    
                    // we put emails that is under the same ContactID together
                    var found = false
                    for (index, var c) in contacts.enumerated() {
                        if let obj = c["ID"] as? String, obj == contactID { // same contactID
                            found = true
                            if var emails = c["ContactEmails"] as? [[String : Any]] {
                                emails.append(email) // insert email
                                c["ContactEmails"] = emails
                            } else {
                                c["ContactEmails"] = [email]
                            }
                            contacts[index] = c
                        }
                    }
                    if !found {
                        let newContact : [String : Any] = [ // this is contact object
                            "ID" : contactID, // contactID
                            "Name" : name, // contact name (email don't have their individual name, so it's contact's name?)
                            "ContactEmails" : [email] // these are the email objects (contact has a relation to email)
                        ]
                        self.contacts.append(newContact)
                    }
                }
            }
        }
        PMLog.D("contacts: \n \(self.contacts.json(prettyPrinted: true))")
        return true
    }
}

class ContactEmailsResponseForContactGroup: Response {
    var total : Int = -1
    var emailList : [[String : Any]] = []
    override func ParseResponse (_ response: [String : Any]!) -> Bool {
        PMLog.D("[Contact] Get contact emails for contact group response \(String(describing: response))")
        
        if let res = response?["ContactEmails"] as? [[String : Any]] {
            emailList = res
        }
        return true
    }
}

// MARK : Get messages part
final class ContactDetailRequest : Request {  //ContactDetailResponse
    let contactID : String
    init(cid : String) {
        self.contactID = cid
    }
    
    var path : String {
        return ContactsAPI.path + "/" + self.contactID
    }
}

//
class ContactDetailResponse : Response {
    var contact : [String : Any]?
    override func ParseResponse (_ response: [String : Any]!) -> Bool {
//      PMLog.D("[Contact] Get contact detail response \(response)")
//        PMLog.D(response.json(prettyPrinted: true))
        contact = response["Contact"] as? [String : Any]
        return true
    }
}


final class ContactEmail : Package {
    let id : String
    let email : String
    let type : String

    // e email  //    "Email": "feng@protonmail.com",
    // t type   //    "Type": "Email" //This type is raw value it is vcard type!!!
    init(e : String, t: String) {
        self.email = e
        self.type = t
        self.id = ""
    }
    
    var parameters: [String : Any]? {
        return [
            "ID" : self.id,
            "Email": self.email,
            "Type": self.type
        ]
    }
}

// 0, 1, 2, 3 // 0 for cleartext, 1 for encrypted only (not used), 2 for signed, 3 for both
enum CardDataType : Int {
    case PlainText = 0
    case EncryptedOnly = 1
    case SignedOnly = 2
    case SignAndEncrypt = 3
}

// add contacts Card object
final class CardData : Package {
    let type : CardDataType
    let data : String
    let sign : String
    
    // t   "Type": CardDataType
    // d   "Data": ""
    // s   "Signature": ""
    init(t : CardDataType, d: String, s : String) {
        self.data = d
        self.type = t
        self.sign = s
    }
    
    var parameters: [String : Any]? {
        return [
            "Data": self.data,
            "Type": self.type.rawValue,
            "Signature": self.sign
        ]
    }
}

extension Array where Element: CardData {
    func toDictionary() -> [[String : Any]] {
        var dicts = [[String : Any]]()
        for element in self {
            if let e = element.parameters {
                dicts.append(e)
            }
        }
        return dicts
    }
}


final class ContactAddRequest : Request {   // ContactAddResponse
    let cardsList : [[CardData]]
    init(cards: [CardData], authCredential: AuthCredential?) {
        self.cardsList = [cards]
        self.auth = authCredential
    }
    
    init(cards: [[CardData]], authCredential: AuthCredential?) {
        self.cardsList = cards
        self.auth = authCredential
    }
    
    //custom auth credentical
    let auth: AuthCredential?
    var authCredential : AuthCredential? {
        get {
            return self.auth
        }
    }
    
    var path : String {
        return ContactsAPI.path
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    
    
    var parameters: [String : Any]? {
        var contacts : [Any] = [Any]()
        for cards in self.cardsList {
            var cards_dict : [Any] = [Any] ()
            for c in cards {
                if let dict = c.parameters {
                    cards_dict.append(dict)
                }
            }
            let contact : [String : Any] = [
                "Cards": cards_dict
            ]
            contacts.append(contact)
        }
        
        return [
            "Contacts" : contacts,
            "Overwrite": 1, // when UID conflict, 0 = error, 1 = overwrite
            "Groups": 1, // import groups if present, will silently skip if group does not exist
            "Labels": 0 // import Notes: change to 0 for now , we need change to 1 later
        ]
    }
}

final class ContactAddResponse : Response {
    var results : [Any?] = []
    override func ParseResponse (_ response: [String : Any]!) -> Bool {
        PMLog.D( response.json(prettyPrinted: true) )
        if let responses = response["Responses"] as? [[String : Any]] {
            for res in responses {
                if let response = res["Response"] as? [String : Any] {
                    let code = response["Code"] as? Int
                    let errorMessage = response["Error"] as? String
                    let errorDetails = errorMessage
                    
                    if code != 1000 && code != 1001 {
                        results.append(NSError.protonMailError(code ?? 1000, localizedDescription: errorMessage ?? "", localizedFailureReason: errorDetails, localizedRecoverySuggestion: nil))
                    } else {
                        results.append(response["Contact"])
                    }
                }
            }
        }
        return true
    }
}

final class ContactDeleteRequest : Request { // Response
    var IDs : [String] = []
    init(ids: [String]) {
        IDs = ids
    }
    
    var path : String {
        return ContactsAPI.path + "/delete"
    }
    
    var method: HTTPMethod {
        return .put
    }
    
    var parameters: [String : Any]? {
        return ["IDs": IDs]
    }
}


final class ContactUpdateRequest : Request { //ContactDetailResponse
    var contactID : String
    let Cards : [CardData]
    
    init(contactid: String, cards: [CardData]) {
        self.contactID = contactid
        self.Cards = cards
    }
    
    var path : String {
        return ContactsAPI.path + "/" + self.contactID
    }
    
    var method: HTTPMethod {
        return .put
    }
    
    var parameters: [String : Any]? {
        var cards_dict : [Any] = [Any] ()
        for c in self.Cards {
            if let dict = c.parameters {
                cards_dict.append(dict)
            }
        }
        return [
            "Cards": cards_dict
        ]
    }
}

// Contact group APIs

/// Add designated contact emails into a certain contact group
final class ContactLabelAnArrayOfContactEmailsRequest: Request { //ContactLabelAnArrayOfContactEmailsResponse
    var labelID: String = ""
    var contactEmailIDs: [String] = []
    init(labelID: String, contactEmailIDs: [String]) {
        self.labelID = labelID
        self.contactEmailIDs = contactEmailIDs
    }
    
    var path : String {
        return ContactsAPI.path + "/emails/label"
    }
    
    var method: HTTPMethod {
        return .put
    }
    
    var parameters: [String : Any]? {
        return ["ContactEmailIDs": contactEmailIDs, "LabelID": labelID]
    }
}


/// Process the response of ContactLabelAnArrayOfContactEmailsRequest
/// TODO: check return body
final class ContactLabelAnArrayOfContactEmailsResponse: Response {
    var emailIDs: [String] = []
    override func ParseResponse (_ response: [String : Any]!) -> Bool {
        //PMLog.D("[Contact] label an array of contact emails response \(response)")
        if let responses = response["Responses"] as? [[String: Any]] {
            for data in responses {
                if let ID = data["ID"] as? String, let tmp = data["Response"] as? [String: Any] {
                    if let code = tmp["Code"] as? Int, code == 1000 {
                        emailIDs.append(ID)
                    }
                }
            }
        }
        return true
    }
}


/// Remove designated contact emails from a certain contact group
final class ContactUnlabelAnArrayOfContactEmailsRequest: Request { //ContactUnlabelAnArrayOfContactEmailsResponse
    var labelID: String = ""
    var contactEmailIDs: [String] = []
    init(labelID: String, contactEmailIDs: [String]) {
        self.labelID = labelID
        self.contactEmailIDs = contactEmailIDs
    }
    
    var path: String {
        return ContactsAPI.path + "/emails/unlabel"
    }
    
    var method: HTTPMethod {
        return .put
    }
    
    var parameters: [String : Any]? {
        return ["ContactEmailIDs": contactEmailIDs, "LabelID": labelID]
    }
}


/// Process the response of ContactUnlabelAnArrayOfContactEmailsRequest
/// TODO: check return body
final class ContactUnlabelAnArrayOfContactEmailsResponse: Response {
    var emailIDs: [String] = []
    
    override func ParseResponse (_ response: [String : Any]!) -> Bool {
        //PMLog.D("[Contact] unlabel an array of contact emails response \(response)")
        if let responses = response["Responses"] as? [[String: Any]] {
            for data in responses {
                if let ID = data["ID"] as? String, let tmp = data["Response"] as? [String: Any] {
                    if let code = tmp["Code"] as? Int, code == 1000 {
                        emailIDs.append(ID)
                    }
                }
            }
        }
        
        return true
    }
}
