//
//  MBProgressHUD+Helper.swift
//  ProtonMail - Created on 2018/10/23.
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
import MBProgressHUD

extension MBProgressHUD {
    // this will make MBProgressHUDs totally untappable. Make sure to fix this one if will need buttons on them
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self.mode == .text ? nil : super.hitTest(point, with: event)
    }
}

extension MBProgressHUD
{
    class func alertToast(errorString: String) -> Void {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: window, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.label.text = LocalString._general_alert_title
        hud.detailsLabel.text = errorString
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 3)
    }
    
    class func alert(at view: UIView, errorString: String) ->Void {
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.label.text = LocalString._general_alert_title
        hud.detailsLabel.text = errorString
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 3)
    }
}
