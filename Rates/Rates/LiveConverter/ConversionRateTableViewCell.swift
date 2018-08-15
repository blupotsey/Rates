//
//  ConversionRateTableViewCell.swift
//  Rates
//
//  Created by Borbas, Adam on 2018. 08. 15..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation
import UIKit

class ConversionRateTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ConversionRateTableViewCell"
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var _conversion: AmountConversion?
    var conversion: AmountConversion? {
        get {
            return self._conversion
        }
        set {
            guard let newConversion = newValue else {
                return
            }
            
            DispatchQueue.main.async {
                self._conversion = newConversion
                self.symbolLabel.text = newConversion.targetSymbol
                self.rateLabel.text = "\(newConversion.rate)"
                self.amountLabel.text = "\(newConversion.amount)"
            }
        }
        
    }
    
}
