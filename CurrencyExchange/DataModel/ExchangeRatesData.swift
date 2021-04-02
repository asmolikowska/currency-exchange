//
//  ExchangeRatesData.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import Foundation
import RealmSwift

struct DataConverted {
    let base: String
    let date: String
    let rates: [Rate]
    var filteredRates: [Rate] {
        get {
            let realm = try? Realm()
            var filteredRates = [Rate]()
            if let realmUnwrapped = realm {
                for rate in self.rates {
                    for object in realmUnwrapped.objects(RateObject.self) {
                        if rate.currency == object.rate?.currency {
                            filteredRates.append(rate)
                        }
                    }
                }
            }
            return filteredRates
        }
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
