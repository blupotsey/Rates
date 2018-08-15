//
//  LiveConverterViewModel.swift
//  Rates
//
//  Created by Borbas, Adam on 2018. 08. 15..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation
import CurrencyConverter

class LiveConverterViewModel {
    private let currencyConverter: CurrencyConverter
    
    var baseAmount: Double = 1.0
    lazy var baseCurrency: CurrencyInfo = {
        guard let currentCurrency = Locale.current.currencyCode else {
            return CurrencyInfo(symbol: "EUR")
        }
        
        // CurrencyInfo(symbol: "currentCurrency"), fixer.io does not allow in the freeplan to set base currency
        return CurrencyInfo(symbol: "EUR")
    }()
    
    init(currencyConverter: CurrencyConverter? = nil) {
        guard let currencyConverter = currencyConverter else {
            self.currencyConverter = FixerCurrencyConverter(apiKey: "aa7098b0974de390918541b6b8dff5d4")
            return
        }
        
        self.currencyConverter = currencyConverter
    }
    
    func conversions(_ completionHandler: @escaping ([AmountConversion]?, Error?) -> Void) {
        self.currencyConverter.latestRates(for: self.baseCurrency) { (rates, error) in
            guard let rates = rates else {
                completionHandler(nil, error!)
                return
            }
            
            let conversions = rates.map { rate in
                return AmountConversion(rate: rate.rate, targetSymbol: rate.target.symbol, baseAmount: self.baseAmount)
            }
            
            completionHandler(conversions, nil)
        }
    }
}
