//
//  UserNotificationsSnoozer.swift
//  ProtonMail - Created on 13/06/2018.
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

@available(iOS 10.0, *)
protocol OptionsDialogPresenter {
    func toSettings()
    func present(_ controller: UIViewController, animated: Bool, completion: (()->Void)?)
}

@available(iOS 10.0, *)
extension OptionsDialogPresenter {
    func toSettings() {
        
    }
}

// controller
@available(iOS 10.0, *)
final class NotificationsSnoozer: NotificationsSnoozerCore {    
    internal func overview(at date: Date,
                           ofCase type: NotificationsSnoozerCore.Configuration.CodingKeys? = nil) -> String
    {
        guard case let activeConfigs = self.activeConfigurations(at: date, ofCase: type), !activeConfigs.isEmpty else {
            return LocalString._notification_snooze
        }
        let descriptions: [String] = activeConfigs.compactMap { $0.localizedDescription(at: date) }
        return descriptions.joined(separator: ", ")
    }
    
    internal func quickOptionsDialog(for date: Date,
                                     toPresentOn presenter: OptionsDialogPresenter,
                                     onStateChangedTo: ((Bool)->Void)? = nil) -> UIViewController
    {
        // time-based options
        let minutes = [30].map { (unit: Measurement<UnitDuration>(value: Double($0), unit: .minutes),
                                  component: DateComponents(minute: $0)) }
        let hours = [1, 2, 4, 8].map { (unit: Measurement<UnitDuration>(value: Double($0), unit: .hours),
                                        component: DateComponents(hour: $0)) }
        var timeBasedOptions = minutes
        timeBasedOptions.append(contentsOf: hours)
        
        // Measurement has plural nouns localization out of the box
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        
        let timeBasedActions = timeBasedOptions.map { time in
            UIAlertAction(title: formatter.string(from: time.unit), style: .default) { _ in
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.unsnoozeNonRepeating()
                let dateWhenUserActivatedSnooze = Date() // here we need date of tap, not creation!
                self.add(.quick(rule: .init(duration: time.component, since: dateWhenUserActivatedSnooze)))
                onStateChangedTo?(true)
            }
        }
        
        let dialog = UIAlertController(title: nil, message: self.overview(at: date), preferredStyle: .actionSheet)
        
        // other actions
        let turnOff = UIAlertAction(title: LocalString._turn_off, style: .destructive) { _ in
            self.unsnoozeNonRepeating()
            onStateChangedTo?(false)
        }
        let custom = UIAlertAction(title: LocalString._custom, style: .default) { _ in
            let configs = self.activeConfigurations(at: date)
            
            var defaultSelection: (Int, Int) = (0, 0)
            if let activeQuickRule = configs.first(where: { $0.belongs(to: .quick) })?.rule,
                let soonestEnd = activeQuickRule.soonestEnd(from: date),
                case let components = Calendar.current.dateComponents([.hour, .minute], from: date, to: soonestEnd),
                let hour = components.hour, let minute = components.minute
            {
                defaultSelection = (hour, minute)
            }
            
            let picker = DurationPickerViewController(select: defaultSelection) { (hour, minute) in
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.unsnoozeNonRepeating()
                let dateWhenUserActivatedSnooze = Date() // since tap, not creation
                self.add(.quick(rule: CalendarIntervalRule(duration: .init(hour: hour, minute: minute), since: dateWhenUserActivatedSnooze)))
                onStateChangedTo?(true)
            }
            presenter.present(picker, animated: true, completion: nil)
        }
        let scheduled = UIAlertAction(title: LocalString._scheduled, style: .default) { _ in
            onStateChangedTo?(self.isSnoozeActive(at: Date()))
            presenter.toSettings()
        }
        let cancel = UIAlertAction(title: LocalString._general_cancel_button, style: .cancel) { _ in
            dialog.dismiss(animated: true, completion: nil)
        }
        
        // bring everything together
        if self.isNonRepeatingSnoozeActive(at: date) {
            [turnOff].forEach( dialog.addAction )
        }
        timeBasedActions.forEach( dialog.addAction )
        [custom, scheduled, cancel].forEach( dialog.addAction )
        
        return dialog
    }
}


@available(iOS 10.0, *)
extension NotificationsSnoozer.Configuration {
    private static var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowsFractionalUnits = false
        formatter.allowedUnits = [.hour, .minute]
        formatter.formattingContext = .middleOfSentence
        formatter.unitsStyle = .short
        return formatter
    }()
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    fileprivate func localizedDescription(at date: Date) -> String? {
        switch self {
        case .quick(rule: let rule):
            guard let soonestEnd = rule.soonestEnd(from: date),
                let formattedString = NotificationsSnoozer.Configuration.durationFormatter.string(from: Date(), to: soonestEnd) else
            {
                return nil
            }
            
            return LocalString._snoozed_for + " " + formattedString
            
        case .scheduled(rule: let rule):
            guard let soonestEnd = rule.soonestEnd(from: date) else {
                return nil
            }
            
            return LocalString._snoozed_till + " " + NotificationsSnoozer.Configuration.dateFormatter.string(from: soonestEnd)
        }
    }
}
