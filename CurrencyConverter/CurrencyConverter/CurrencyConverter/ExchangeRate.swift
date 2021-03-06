//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by Borbas, Adam on 2018. 08. 14..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation

public struct ExchangeRate {
    public let base: CurrencyInfo
    public let target: CurrencyInfo
    public let rate: Double
}
