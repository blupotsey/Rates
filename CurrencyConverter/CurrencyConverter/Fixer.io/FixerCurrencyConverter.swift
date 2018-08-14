//
//  FixerCurrencyConverter.swift
//  CurrencyConverter
//
//  Created by Borbas, Adam on 2018. 08. 14..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation
import Alamofire

public class FixerCurrencyConverter: CurrencyConverter {
    private let apiKey: String
    private lazy var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    private static let defaultSymbol = "GBP"
    
    private var defaultParameters: Parameters {
        return [
            API.Key.apiKey: self.apiKey
        ]
    }
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func supportedCurrencies(_ completionHandler: @escaping ([Currency]?, Error?) -> Void) {
        let url = API.baseURL.appendingPathComponent(API.Path.symbols)
        
        Alamofire.request(url, parameters: self.defaultParameters).responseJSON { response in
            switch response.result {
            case .success(let rawJSON):
                guard let json = rawJSON as? [String: Any],
                    let rawSymbols = json[API.Response.symbols] as? [String: String] else {
                        print("Cannot parse symbols.")
                        completionHandler(nil, FixerCurrencyConverterError.invalidJSON)
                        return
                }
                
                let symbols = rawSymbols.map {(key, value) in
                    return Currency(symbol: key, name: value)
                }
                
                completionHandler(symbols, nil)
                
            case .failure(let error):
                completionHandler(nil, FixerCurrencyConverterError.networkError(error))
            }
        }
    }
    
    public func latestRates(for currency: Currency? = nil, _ completionHandler: @escaping ([ExchangeRate]?, Error?) -> Void) {
        let url = API.baseURL.appendingPathComponent(API.Path.latest)
        var parameters = self.defaultParameters
        if let currency = currency {
            parameters[API.Key.base] = currency.symbol
        }
    
        let dataRequest = Alamofire.request(url, parameters: parameters)
        self.consumeRatesDataRequest(baseCurrency: currency, dataRequest, completionHandler)
    }
    
    public func historicalRates(for currency: Currency? = nil, at date: Date, _ completionHandler: @escaping ([ExchangeRate]?, Error?) -> Void) {
        let url = API.baseURL.appendingPathComponent(self.dateFormatter.string(from: date))
        var parameters = self.defaultParameters
        if let currency = currency {
            parameters[API.Key.base] = currency.symbol
        }
        
        let dataRequest = Alamofire.request(url, parameters: parameters)
        self.consumeRatesDataRequest(baseCurrency: currency , dataRequest, completionHandler)
    }
    
    private func consumeRatesDataRequest(baseCurrency: Currency? = nil, _ dataRequest: DataRequest, _ completionHandler: @escaping ([ExchangeRate]?, Error?) -> Void) {
        dataRequest.responseJSON { response in
            switch response.result {
            case .success(let rawJSON):
                guard let json = rawJSON as? [String: Any],
                    let rawRates = json[API.Response.rates] as? [String: Double] else {
                        print("Cannot parse rates.")
                        completionHandler(nil, FixerCurrencyConverterError.invalidJSON)
                        return
                }
                
                let rates = rawRates.map { (symbol, rate) -> ExchangeRate in
                    return ExchangeRate(base: CurrencyInfo(symbol: baseCurrency?.symbol ?? FixerCurrencyConverter.defaultSymbol), target: CurrencyInfo(symbol: symbol), rate: rate)
                }
                
                completionHandler(rates, nil)
                
            case .failure(let error):
                completionHandler(nil, FixerCurrencyConverterError.networkError(error))
            }
        }
    }
}

private enum API {
    static let baseURL = URL(string: "http://data.fixer.io/api")!
    
    enum Key {
        static let apiKey = "access_key"
        static let base = "base"
    }
    
    enum Path {
        static let symbols = "symbols"
        static let latest = "latest"
    }
    
    enum Response {
        static let symbols = "symbols"
        static let rates = "rates"
    }
}
