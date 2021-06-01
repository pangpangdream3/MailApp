//
//  UserNotificationsSnoozer.swift
//  ProtonMail - Created on 05/06/2018.
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

// model
class NotificationsSnoozerCore {
    
    internal enum Configuration {
        case quick(rule: CalendarIntervalRule)
        case scheduled(rule: CalendarIntervalRule)
        
        internal func evaluate(at date: Date) -> Bool {
            switch self {
            case .quick(rule: let rule), .scheduled(rule: let rule):
                return rule.intersects(with: date)
            }
        }
        
        internal func belongs(to type: CodingKeys) -> Bool {
            switch self {
            case .quick where type == .quick,
                 .scheduled where type == .scheduled: return true
            default: return false
            }
        }
        
        internal var rule: CalendarIntervalRule {
            switch self {
            case .quick(rule: let rule), .scheduled(rule: let rule):
                return rule
            }
        }
    }
    
    internal func configs(ofCase type: Configuration.CodingKeys? = nil) -> [Configuration] {
        guard let configs = userCachedStatus.snoozeConfiguration else {
            return []
        }
        guard let type = type else {
            return configs
        }
        return configs.filter {
            switch $0 {
            case Configuration.quick where type == .quick: return true
            case Configuration.scheduled where type == .scheduled: return true
            default: return false
            }
        }
    }
    
    // TODO: evaluated configs can be cached here
    
    // check if snoozed currently
    internal func isSnoozeActive(at date: Date) -> Bool {
        return self.configs().contains { $0.evaluate(at: date) }
    }
    
    internal func isNonRepeatingSnoozeActive(at date: Date) -> Bool {
        return self.configs(ofCase: .quick).contains { $0.evaluate(at: date) }
    }
    
    internal func activeConfigurations(at date: Date, ofCase type: Configuration.CodingKeys? = nil) -> [Configuration] {
        return self.configs(ofCase: type).filter { $0.evaluate(at: date) }
    }
    
    // set snooze config
    internal func add(_ configurations: [Configuration]) {
        var currentSettings = userCachedStatus.snoozeConfiguration
        currentSettings?.append(contentsOf: configurations)
        userCachedStatus.snoozeConfiguration = currentSettings
    }
    internal func add(_ configuration: Configuration) {
        var currentSettings = userCachedStatus.snoozeConfiguration
        currentSettings?.append(configuration)
        userCachedStatus.snoozeConfiguration = currentSettings
    }
    
    // remove snooze config
    private func unsnooze(_ configurations: [Configuration]) {
        guard var currentSettings = userCachedStatus.snoozeConfiguration else {
            return
        }
        currentSettings = currentSettings.filter { !configurations.contains($0) }
        userCachedStatus.snoozeConfiguration = currentSettings
    }
    
    internal func unsnoozeNonRepeating() {
        self.unsnooze(self.configs(ofCase: .quick))
    }
    
    internal func unsnoozeRepeating() {
        self.unsnooze(self.configs(ofCase: .scheduled))
    }
}

// utilitary

extension NotificationsSnoozerCore.Configuration: Encodable, Decodable {
    internal enum CodingKeys: CodingKey {
        case quick
        case scheduled
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .quick(let rule):
            try container.encode(rule, forKey: .quick)
        case .scheduled(let rules):
            try container.encode(rules, forKey: .scheduled)
        }
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let quick =  try? container.decode(CalendarIntervalRule.self, forKey: .quick) {
            self = .quick(rule: quick)
            return
        }
        
        if let scheduled =  try? container.decode(CalendarIntervalRule.self, forKey: .scheduled) {
            self = .scheduled(rule: scheduled)
            return
        }
        
        throw NSError(domain: "\(NotificationsSnoozerCore.self)", code: 0, localizedDescription: "Failed to decode value from container")
    }
}

extension NotificationsSnoozerCore.Configuration: Equatable {
    internal static func == (lhs: NotificationsSnoozerCore.Configuration, rhs: NotificationsSnoozerCore.Configuration) -> Bool {
        switch (lhs, rhs) {
        case (.quick(let x1), .quick(let x2)) where x1 == x2: return true
        case (.scheduled(let x1), .scheduled(let x2)) where x1 == x2: return true
        default: return false
        }
    }
}
