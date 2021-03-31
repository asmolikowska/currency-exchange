//
//  ExchangeRatesData.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import Foundation

struct ExchangeRatesData: Decodable {
    let base: String
    let date: String
    let rates: [String: Decimal]
    
    func getRates() -> [Rate] {
        var ratesArray: [Rate] = []
        for (value, key) in rates {
            let rate = Rate(currency: value, value: key)
            ratesArray.append(rate)
        }
        return ratesArray
    }
}

struct Rate {
    let currency: String
    let value: Decimal
}
