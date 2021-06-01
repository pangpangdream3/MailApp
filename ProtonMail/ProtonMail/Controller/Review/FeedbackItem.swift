//
//  FeedbackItem.swift
//  ProtonMail - Created on 3/14/16.
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


enum FeedbackItem: String {
    case header = "Header"
    case rate = "Report Bugs"
    case tweet = "Inbox"
    case facebook = "Starred"
    case contact = "Archive"
    case guide = "Drafts"
    
    var identifier: String { return rawValue }
    
    var image : String {
        switch self {
        case .header:
            return ""
        case .rate:
            return "feedback_rating"
        case .tweet:
            return "feedback_twitter"
        case .facebook:
            return "feedback_facebook"
        case .contact:
            return "feedback_contact"
        case .guide:
            return "feedback_support"
        }
    }
    
    var title : String {
        switch self {
        case .header:
            return ""
        case .rate:
            return LocalString._rate_review
        case .tweet:
            return LocalString._tweet_about_protonmail
        case .facebook:
            return LocalString._share_it_with_your_friends
        case .contact:
            return LocalString._contact_the_protonmail_team
        case .guide:
            return LocalString._trouble_shooting_guide
        }
    }
}


enum FeedbackSection: Int {
    case header = 0
    case reviews = 1
    case guid = 2
    case helping = 3 //"Help us to improve ProtonMail with your input"
    
    var identifier: Int { return rawValue }
    
    var hasTitle : Bool {
        var has = false
        switch self {
        case .reviews, .guid, .helping:
            has = true
        default:
            has = false
        }
        return has;
    }
    
    var title : String {
        switch self {
        case .header:
            return ""
        case .reviews:
            return LocalString._help_us_to_make_privacy_the_default_in_the_web
        case .guid:
            return LocalString._help_us_to_improve_protonmail_with_your_input
        case .helping:
            return LocalString._we_would_like_to_know_what_we_can_do_better
        }
    }
}

