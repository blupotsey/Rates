//
//  FixerCurrencyConverterError.swift
//  CurrencyConverter
//
//  Created by Borbas, Adam on 2018. 08. 14..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation

enum FixerCurrencyConverterError: Error {
    case invalidJSON
    case networkError(Error)
    case serviceError(FixerServiceError)
}

extension FixerCurrencyConverterError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "Please try again later."
            
        case .networkError(let error):
            return error.localizedDescription
            
        case .serviceError(let error):
            return error.type
        }
    }
}

