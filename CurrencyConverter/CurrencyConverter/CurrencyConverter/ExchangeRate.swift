//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by Borbas, Adam on 2018. 08. 14..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation

public struct ExchangeRate {
    let base: Currency
    let target: Currency
    let rate: Double
}
