//
//  CurrencyHistoryViewController.swift
//  Rates
//
//  Created by Borbas, Adam on 2018. 08. 18..
//  Copyright © 2018. Adam Borbas. All rights reserved.
//

import Foundation
import UIKit
import CurrencyConverter

class CurrencyHistoryViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateStepper: UIStepper!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var currencyConverter: CurrencyConverter!
    var currencyInfo: CurrencyInfo!
    private var verticalOffset: CGFloat?
    private var date: Date = Date()
    private var rates = [ExchangeRate]()
    private lazy var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpUI()
    }
    
    // MARK: - Actionn
    @IBAction func stepperChanged(_ sender: Any) {
        self.dateChanged()
    }
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Private functions
    private func loadRates() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.dateStepper.isEnabled = false
        }
        
        self.currencyConverter.historicalRates(for: self.currencyInfo, at: self.date) { (rates, error) in
            defer { DispatchQueue.main.async { self.activityIndicator.stopAnimating() } }
            
            guard let rates = rates else {
                let alertController = UIAlertController(title: "Failed to load rates!", message:
                    error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            DispatchQueue.main.async {
                self.rates = rates.sorted(by: { $0.target.symbol < $1.target.symbol })
                self.tableView.reloadData()
                self.dateStepper.isEnabled = true
                
                if let offset = self.verticalOffset {
                    self.tableView.contentOffset = CGPoint(x: 0, y: offset)
                }
            }
        }
    }
    
    private func setUpUI() {
        self.dateChanged()
    }
    
    fileprivate func dateChanged() {
        DispatchQueue.main.async {
            self.verticalOffset = self.tableView.contentOffset.y
            self.date = Calendar.current.date(byAdding: .day, value: Int(self.dateStepper.value), to: Date())!
            self.dateLabel.text = self.dateFormatter.string(from: self.date)
            self.rates.removeAll()
            self.tableView.reloadData()
            
            self.loadRates()
        }
    }
}

extension CurrencyHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HistoryRatesTableViewCell", for: indexPath)
        
        let rate = self.rates[indexPath.row]
        cell.textLabel?.text = rate.target.symbol
        cell.detailTextLabel?.text = "\(rate.rate)"
        return cell
    }
}
