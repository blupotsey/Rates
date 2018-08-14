//
//  FixerCurrencyConverterIntegrationTests.swift
//  CurrencyConverterIntegrationTests
//
//  Created by Borbas, Adam on 2018. 08. 14..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation
import XCTest
import CurrencyConverter

class FixerCurrencyConverterIntegrationTests: XCTestCase {
    private var fixerConverter: FixerCurrencyConverter!
    private let apiKey = "aa7098b0974de390918541b6b8dff5d4"
    
    override func setUp() {
        super.setUp()
        
        self.fixerConverter = FixerCurrencyConverter(apiKey: self.apiKey)
    }
    
    func test_supportedCurrencies_returnsNonNil() {
        let expectation = XCTestExpectation()
        
        fixerConverter.supportedCurrencies { (currencies, error) in
            defer { expectation.fulfill() }
            
            XCTAssertNil(error, "Successfull response should not contain error.")
            XCTAssertNotNil(currencies, "Successfull response should contain currencies.")
            if let currencies = currencies {
                XCTAssertFalse(currencies.isEmpty)
            }
        }
        
        self.wait(for: [expectation], timeout: 30)
    }
    
    func test_latestRate_returnsNonNil() {
        let expectation = XCTestExpectation()
        
        fixerConverter.latestRates() { (rates, error) in
            defer { expectation.fulfill() }
            
            XCTAssertNil(error, "Successfull response should not contain error.")
            XCTAssertNotNil(rates, "Successfull response should contain rates.")
            if let rates = rates {
                XCTAssertFalse(rates.isEmpty)
            }
        }
        
        self.wait(for: [expectation], timeout: 30)
    }
    
    func test_historicalRate_returnsNonNil() {
        let expectation = XCTestExpectation()
        
        fixerConverter.historicalRates(at: Calendar.current.date(byAdding: .day, value: -1, to: Date())!) { (rates, error) in
            defer { expectation.fulfill() }
            
            XCTAssertNil(error, "Successfull response should not contain error.")
            XCTAssertNotNil(rates, "Successfull response should contain rates.")
            if let rates = rates {
                XCTAssertFalse(rates.isEmpty)
            }
        }
        
        self.wait(for: [expectation], timeout: 30)
    }
    
}
