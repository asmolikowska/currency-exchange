//
//  ExchangeRatesData.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import Foundation

class DataConverted {
    let base: String
    let date: String
    let rates: [Rate]
    var filteredRates: [Rate]
    
    init(base: String, date: String, rates: [Rate], filteredRates: [Rate]) {
        self.base = base
        self.date = date
        self.rates = rates
        self.filteredRates = filteredRates
        initializeFiltered()
    }
    
    func initializeFiltered() {
        var filteredRates = [Rate]()
        let defaults = UserDefaults.standard
        if defaults.array(forKey: "Currencies") != nil {
            for rate in self.rates {
                for value in defaults.array(forKey: "Currencies") as! [String] {
                    if rate.currency == value {
                        filteredRates.append(rate)
                    }
                }
                
            }
        }
        self.filteredRates = filteredRates
    }
}

struct ExchangeRatesData: Decodable {
    let base: String
    let date: String
    let rates: [String: Double]
}

struct Rate: Codable {
    let currency: String
    let value: Double
}
