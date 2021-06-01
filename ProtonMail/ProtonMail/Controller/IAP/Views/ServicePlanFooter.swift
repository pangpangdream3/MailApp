//
//  ServicePlanFooter.swift
//  ProtonMail - Created on 12/08/2018.
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

class ServicePlanFooter: UIView {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var subtitle: UILabel!
    private var buttonAction: ((UIButton?)->Void)?
    
    override func prepareForInterfaceBuilder() {
        self.setupSubviews()
    }
    
    convenience init(title: NSAttributedString? = nil,
                     subTitle: String? = nil,
                     buttonTitle: NSAttributedString? = nil,
                     buttonEnabled: Bool = true,
                     buttonAction: ((UIButton?)->Void)?=nil)
    {
        self.init(frame: .zero)
        defer {
            self.setup(title: title, subTitle: subTitle, buttonTitle: buttonTitle, buttonEnabled: buttonEnabled, buttonAction: buttonAction)
        }
    }
    
    func setup(title: NSAttributedString? = nil,
               subTitle: String? = nil,
               buttonTitle: NSAttributedString? = nil,
               buttonEnabled: Bool = true,
               buttonAction: ((UIButton?)->Void)?=nil)
    {
        self.title.attributedText = title
        self.subtitle.text = subTitle
        
        if buttonTitle != nil {
            self.buyButton.setAttributedTitle(buttonTitle, for: .normal)
            self.buyButton.titleLabel?.numberOfLines = 0
            self.buyButton.titleLabel?.lineBreakMode = .byWordWrapping
            self.buyButton.titleLabel?.textAlignment = .center
            self.buttonAction = buttonAction
            self.buyButton.addTarget(self, action: #selector(self.performButtonAction), for: .touchUpInside)
            self.style(buttonEnabled: buttonEnabled)
        } else {
            self.buyButton.isHidden = true
        }
    }
    
    private func style(buttonEnabled: Bool) {
        DispatchQueue.main.async {
            self.buyButton.isUserInteractionEnabled = buttonEnabled
            self.buyButton.backgroundColor = buttonEnabled ? UIColor.ProtonMail.ButtonBackground : UIColor.ProtonMail.TableSeparatorGray
        }
    }
    
    @objc private func performButtonAction() {
        self.style(buttonEnabled: false)
        self.buttonAction?(self.buyButton)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()
        self.setupSubviews()
    }
    
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.buyButton.roundCorners()
        self.buyButton.backgroundColor = UIColor.ProtonMail.ButtonBackground
    }
}
