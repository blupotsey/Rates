//
//  FixerCurrencyConverter.swift
//  CurrencyConverter
//
//  Created by Borbas, Adam on 2018. 08. 14..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation
import Alamofire

/**
 `CurrencyConverter` implementation using Fixer.io service.
 */
public class FixerCurrencyConverter: CurrencyConverter {
    private let apiKey: String
    private lazy var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    private static let defaultSymbol = "EUR"
    
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
        let request = Alamofire.request(url, parameters: self.defaultParameters)
        
        self.sendFixerDataRequest(request) { result in
            switch result {
            case .success(let json):
                guard let rawSymbols = json[API.Response.symbols] as? [String: String] else {
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
    
    public func latestRates(for currency: CurrencyInfo? = nil, _ completionHandler: @escaping ([ExchangeRate]?, Error?) -> Void) {
        let url = API.baseURL.appendingPathComponent(API.Path.latest)
        var parameters = self.defaultParameters
        if let currency = currency {
            parameters[API.Key.base] = currency.symbol
        }
        
        let dataRequest = Alamofire.request(url, parameters: parameters)
        self.sendRatesDataRequest(baseCurrency: currency, dataRequest, completionHandler)
    }
    
    public func historicalRates(for currency: CurrencyInfo? = nil, at date: Date, _ completionHandler: @escaping ([ExchangeRate]?, Error?) -> Void) {
        let url = API.baseURL.appendingPathComponent(self.dateFormatter.string(from: date))
        var parameters = self.defaultParameters
        if let currency = currency {
            parameters[API.Key.base] = currency.symbol
        }
        
        let dataRequest = Alamofire.request(url, parameters: parameters)
        self.sendRatesDataRequest(baseCurrency: currency , dataRequest, completionHandler)
    }
    
    // MARK: - Private functions
    
    private func sendFixerDataRequest(_ dataRequest: DataRequest, _ completionHandler: @escaping (Alamofire.Result<[String: Any]>) -> Void) {
        dataRequest.responseJSON { response in
            switch response.result {
            case .success(let rawJSON):
                guard let json = rawJSON as? [String: Any] else {
                    print("Not valid JSON")
                    completionHandler(.failure(FixerCurrencyConverterError.invalidJSON))
                    return
                }
                
                if let rawError = json[API.Response.Error.error] as? [String: Any],
                    let code = rawError[API.Response.Error.code] as? Int,
                    let type = rawError[API.Response.Error.type] as? String {
                    let serviceError = FixerServiceError(code: code, type: type)
                    completionHandler(.failure(FixerCurrencyConverterError.serviceError(serviceError)))
                    return
                }
                
                completionHandler(.success(json))
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func sendRatesDataRequest(baseCurrency: CurrencyInfo? = nil, _ dataRequest: DataRequest, _ completionHandler: @escaping ([ExchangeRate]?, Error?) -> Void) {
        
        self.sendFixerDataRequest(dataRequest) { result in
            switch result {
            case .success(let json):
                guard let rawRates = json[API.Response.rates] as? [String: Double] else {
                    print("Cannot parse rates.")
                    completionHandler(nil, FixerCurrencyConverterError.invalidJSON)
                    return
                }
                
                let rates = rawRates.map { (symbol, rate) -> ExchangeRate in
                    return ExchangeRate(base: CurrencyInfo(symbol: baseCurrency?.symbol ?? FixerCurrencyConverter.defaultSymbol), target: CurrencyInfo(symbol: symbol), rate: rate)
                }
                
                completionHandler(rates, nil)
                
            case .failure(let error):
                completionHandler(nil, error)
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
        
        enum Error {
            static let error = "error"
            static let code = "code"
            static let type = "type"
        }
    }
}
