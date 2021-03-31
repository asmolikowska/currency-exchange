//
//  CurrencyCounterViewController.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import UIKit
import SwiftSpinner


class CurrencyCounterViewController: UITableViewController {
    
    var currencyApiManager = CurrencyApiManager()
    var currency = "USD"
    var exchangeRates: ExchangeRatesData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show(progress: 0.2, title: "Downloading Data...")
        currencyApiManager.performRequest(baseCurrency: currency) {data in
            if let safeData = data {
                self.exchangeRates = self.currencyApiManager.parseData(exchangeRatesData: safeData)
                //reload data
                SwiftSpinner.hide()
            }
        }
    }
    
    
}

