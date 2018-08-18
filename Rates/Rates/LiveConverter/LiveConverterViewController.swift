//
//  LiveConverterViewController.swift
//  Rates
//
//  Created by Borbas, Adam on 2018. 08. 15..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation
import UIKit
import CurrencyConverter

class LiveConverterViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var baseAmountTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var historyButton: UIBarButtonItem!
    
    // MARK: - Properties
    private let viewModel = LiveConverterViewModel()
    private var conversions = [AmountConversion]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currencyChanged()
    }
    
    // MARK: - Actions
    @IBAction func doneTapped(_ sender: Any) {
        guard let amount = Double(self.baseAmountTextField.text!) else {
            return
        }
        
        self.baseAmountTextField.endEditing(true)
        self.viewModel.baseAmount = amount
        self.loadRates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectCurrencySegue" {
            let currencySelectorVC = (segue.destination as! UINavigationController).viewControllers.first! as! CurrencySelectorViewController
            currencySelectorVC.currencyConverter = self.viewModel.currencyConverter
            currencySelectorVC.delegate = self
            return
        }
        
        if segue.identifier == "ShowHistorySegue" {
            let currencyHistoryVC = (segue.destination as! UINavigationController).viewControllers.first! as! CurrencyHistoryViewController
            currencyHistoryVC.currencyConverter = self.viewModel.currencyConverter
            return
        }
    }
    
    // MARK: - Private functions
    private func loadRates() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.doneButton.isEnabled = false
            self.historyButton.isEnabled = false
        }
        
        self.viewModel.conversions { (conversions, error) in
            defer { DispatchQueue.main.async { self.activityIndicator.stopAnimating() }}
            
            guard let conversions = conversions else {
                self.presentAlert(for: error!)
                return
            }
            
            DispatchQueue.main.async {
                self.conversions = conversions.sorted(by: { $0.targetSymbol < $1.targetSymbol})
                self.tableView.reloadData()
                
                self.doneButton.isEnabled = true
                self.historyButton.isEnabled = true
            }
        }
    }
    
    private func presentAlert(for error: Error) {
        let alertController = UIAlertController(title: "Failed to load rates!", message:
            error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func currencyChanged() {
        DispatchQueue.main.async {
            self.conversions.removeAll()
            self.tableView.reloadData()
            
            self.navigationItem.title = self.viewModel.baseCurrency.symbol
            self.loadRates()
        }
    }
}

extension LiveConverterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ConversionRateTableViewCell.reuseIdentifier, for: indexPath) as! ConversionRateTableViewCell
        
        let amountConversion = self.conversions[indexPath.row]
        cell.conversion = amountConversion
        return cell
    }
}

extension LiveConverterViewController: CurrencySelectorDelegate {
    func currencySelected(_ currency: Currency) {
        self.viewModel.baseAmount = 1
        self.baseAmountTextField.text = "\(Int(self.viewModel.baseAmount))"
        self.viewModel.baseCurrency = currency.info
        
        self.currencyChanged()
    }
}
