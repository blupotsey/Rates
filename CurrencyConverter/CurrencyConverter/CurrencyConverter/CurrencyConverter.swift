//
//  CurrencyConverter.swift
//  CurrencyConverter
//
//  Created by Borbas, Adam on 2018. 08. 14..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation

/// Represents a type that provides currency conversion rates.
public protocol CurrencyConverter {
    
    /// Returns the list of supported currencies.
    func supportedCurrencies(_ completionHandler: @escaping ([Currency]?, Error?) -> Void)
    
    /// Returns the latest exchange rates for a given `Currency`.
    func latestRates(for currency: CurrencyInfo?, _ completionHandler: @escaping ([ExchangeRate]?, Error?) -> Void)
    
    /// Returns the historical exchange rates for a given `Currency` at a given `Date`.
    func historicalRates(for currency: CurrencyInfo?, at date: Date, _ completionHandler: @escaping ([ExchangeRate]?, Error?) -> Void)
}
