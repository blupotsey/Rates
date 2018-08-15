//
//  AmountConversion.swift
//  Rates
//
//  Created by Borbas, Adam on 2018. 08. 15..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation

class AmountConversion {
    let rate: Double
    let targetSymbol: String
    let baseAmount: Double
    
    var amount: Double {
        return self.baseAmount * self.rate
    }
    
    init(rate: Double, targetSymbol: String, baseAmount: Double) {
        self.rate = rate
        self.targetSymbol = targetSymbol
        self.baseAmount = baseAmount
    }
}
