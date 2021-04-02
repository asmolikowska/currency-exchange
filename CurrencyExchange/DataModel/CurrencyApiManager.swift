//
//  CurrencyApiManager.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import Foundation

class CurrencyApiManager {
    let baseUrl = "http://api.exchangeratesapi.io/latest"
    let apiKey = "2ae2b120476562b15785404dfee4c630"
    
    func performRequest(completion: @escaping (Data?) -> ()) {
        let urlString = "\(baseUrl)?access_key=\(apiKey)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                completion(data)
            }
            task.resume()
        }
    }    
    
    func parsToConvertedeData(data: Data) -> DataConverted? {
        let decoder = JSONDecoder()
        var ratesArray: [Rate] = []
        do {
            let decodedData = try decoder.decode(ExchangeRatesData.self, from: data)
            for (value, key) in decodedData.rates {
                let rate = Rate(currency: value, value: key)
                ratesArray.append(rate)
            }
            return DataConverted(base: decodedData.base, date: decodedData.date, rates: ratesArray, filteredRates: [])
        } catch {
            print(error)
            return nil
        }
    }

}
