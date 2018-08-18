//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Borbas, Adam on 2018. 08. 14..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation

public struct Currency {
    public let symbol: String
    public let name: String
    
    public var info: CurrencyInfo {
        return CurrencyInfo(symbol: self.symbol)
    }
    
    public init(symbol: String, name: String) {
        self.symbol = symbol
        self.name = name
    }
}
