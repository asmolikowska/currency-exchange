//
//  ExchangeRatesData.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import Foundation
import RealmSwift

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

struct Rate: Codable {
    let currency: String
    let value: Decimal
}

class RateObject : Object {
    @objc private dynamic var structData: Data? = nil
    
    var rate : Rate? {
        get {
            if let data = structData {
                return try? JSONDecoder().decode(Rate.self, from: data)
            }
            return nil
        }
        set {
            structData = try? JSONEncoder().encode(newValue)
        }
    }
}
