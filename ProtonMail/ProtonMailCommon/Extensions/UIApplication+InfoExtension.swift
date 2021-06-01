//
//  UIApplication+InfoExtension.swift
//  ProtonMail - Created on 8/21/15.
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

enum UIApplicationReleaseMode: Int {
    case unknown = 0
    case sim = 1
    case dev = 2
    case adHoc = 3
    case appStore = 4
    case enterprise = 5
};

extension UIApplication {
    
    func getMobileProvision() -> [String : Any]? {
        struct MP {
            static var mobileProvision : [String : Any]? = nil;
        }
        
        if MP.mobileProvision == nil {
            guard let provisioningPath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") else {
                MP.mobileProvision = [String : String]() as [String : Any]?;
                return MP.mobileProvision;
            }
            
            do {
                let binaryString = try String(contentsOfFile: provisioningPath, encoding: String.Encoding.isoLatin1)
                let scanner : Scanner = Scanner(string: binaryString)
                var ok : Bool = scanner.scanUpTo("<plist" , into: nil)
                if !ok {
                    PMLog.D("unable to find beginning of plist");
                    //return UIApplicationReleaseUnknown;
                }
                
                var plistString : NSString?
                ok = scanner.scanUpTo("</plist>" , into: &plistString)
                if !ok {
                    PMLog.D("unable to find end of plist");
                    //return UIApplicationReleaseUnknown;
                }
                let newStr = String("\(plistString!)</plist>")
                // juggle latin1 back to utf-8!
                let plistdata_latin1 : Data = newStr.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)!
                
                MP.mobileProvision = try PropertyListSerialization.propertyList(from: plistdata_latin1, options: PropertyListSerialization.ReadOptions(rawValue: 0), format: nil) as? [String : Any]
            } catch {
                PMLog.D("error parsing extracted plist — \(error)");
                MP.mobileProvision = nil;
                return nil;
            }
        }
        return MP.mobileProvision
    }
    
    
    func releaseMode() -> UIApplicationReleaseMode {
    
        let mobileProvision = self.getMobileProvision()
        if mobileProvision == nil {
            // failure to read other than it simply not existing
            return .unknown
        } else if mobileProvision?.count == 0 {
            #if targetEnvironment(simulator)
                return .sim;
            #else
                return .appStore;
            #endif
        }
        else if self.checkProvisionsAllDevices(mobileProvision!) {
            // enterprise distribution contains ProvisionsAllDevices - true
            return .enterprise;
        } else if self.checkProvisionsDevices(mobileProvision!) {
            // development contains UDIDs and get-task-allow is true
            // ad hoc contains UDIDs and get-task-allow is false
            let entitlements : [String : Any]? = mobileProvision!["Entitlements"] as? [String : Any]
            if (entitlements == nil) {
                return .adHoc
            }
            let getTaskAllow = entitlements!["get-task-allow"] as? Bool ?? false
            if (getTaskAllow) {
                return .dev;
            } else {
                return .adHoc;
            }
        } else {
            // app store contains no UDIDs (if the file exists at all?)
            return .appStore
        }
    }
    
    func checkProvisionsAllDevices(_ dict : [String : Any]) -> Bool {
        if let check : Bool = dict["ProvisionsAllDevices"] as? Bool {
            return check
        } else {
            return false
        }
    }
    
    func checkProvisionsDevices(_ dict : [String : Any]) -> Bool {
        if let devices : [Any] = dict["ProvisionedDevices"] as? [Any] {
            if devices.count > 0 {
                return true
            } else {
                return false;
            }
        } else {
            return false
        }
    }
}
