//
//  CurrencySelectorViewController.swift
//  Rates
//
//  Created by Borbas, Adam on 2018. 08. 16..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation
import UIKit
import CurrencyConverter

class CurrencySelectorViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var currencyConverter: CurrencyConverter!
    private var currencies = [Currency]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadCurrencies()
    }
    
    // MARK: - Actions
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Private functions
    private func loadCurrencies() {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        
        self.currencyConverter.supportedCurrencies { (currencies, error) in
            defer { DispatchQueue.main.async { self.activityIndicator.stopAnimating() }}
            
            guard let currencies = currencies else {
                let alertController = UIAlertController(title: "Failed to load currencies!", message:
                    error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default,handler: nil))
                return
            }
            
            DispatchQueue.main.async {
                self.currencies = currencies.sorted(by: { $0.symbol < $1.symbol })
                self.tableView.reloadData()
            }
        }
    }
}

extension CurrencySelectorViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CurrencySelectorTableViewCell")!
        let currency = self.currencies[indexPath.row]
        cell.textLabel?.text = currency.symbol
        cell.detailTextLabel?.text = currency.name
        
        return cell
    }
}
