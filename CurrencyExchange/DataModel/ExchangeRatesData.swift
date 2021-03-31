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
}
