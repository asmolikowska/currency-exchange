//
//  CurrencyCounterViewModel.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 31/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

enum CurrencyCounterSection {
    case headerCounterSection
    case currencies
    case addMoreCurrencies
}

class CurrencyCounterViewModel: PrimaryViewModel {
    
    var shouldDisplayActivityIndicator = BehaviorRelay<Bool>(value: false)
    var showErrorMessageContent = BehaviorRelay<String?>(value: nil)
    var reloadLst = BehaviorRelay<Bool>(value: false)
    var currencyApiManager = CurrencyApiManager()
    var dataConverted: DataConverted?
    var sections: [CurrencyCounterSection] = [.headerCounterSection , .currencies, .addMoreCurrencies]
    
    func getDashboardData(completion: @escaping() -> Void) {
        shouldDisplayActivityIndicator.accept(true)
        currencyApiManager.performRequest { data in
            if let safeData = data {
                self.dataConverted = self.currencyApiManager.parseToConvertedeData(data: safeData)
                self.reloadLst.accept(true)
                self.shouldDisplayActivityIndicator.accept(false)
            }
        }
    }
    
    
    
    func refresh() {
        reloadLst.accept(true)
    }
    
    //    func saveCurrency(name: String) {
    //        getUserStoredRatesData()
    //        if let realm = realm {
    //            if !isAlreadyInDatabase(for: name) {
    //                try? realm.write {
    //                    let rateObjectEUR = RateObject()
    //                    rateObjectEUR.rate = Rate(currency: name, value: 0.0)
    //                    realm.add(rateObjectEUR)
    //                }
    //            }
    //        }
    //        refresh()
    //    }
    
    func isAlreadyStoredCurrency(for name: String) -> Bool {
        let defaults = UserDefaults.standard
        if let defaultCurrency = defaults.array(forKey: "Currencies") as? [String] {
            for value in defaultCurrency {
                if value == name {
                    return true
                }
            }
        }
        return false
    }
    
    func setPrimaryCurrencies() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "IsCurrencyArrayInit") {
            defaults.set(["USD", "EUR", "GBP", "CAD"], forKey: "Currencies")
            defaults.set(true, forKey: "IsCurrencyArrayInit")
        }
        refresh()
    }
    
    func setDefaultCurrencyToUserDefaults(currency: String?) {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "Currency") != nil {
            defaults.set(currency, forKey: "Currency")
        } else {
            defaults.set("PLN", forKey: "Currency")
        }
        self.reloadLst.accept(true)
    }
    
    func setCurrenciesToUserDefaults(currency: String) {
        let defaults = UserDefaults.standard
        var array = [String]()
        let saved = defaults.array(forKey: "Currencies") as! [String]
        array = saved
        array.append(currency)
        defaults.set(array, forKey: "Currencies")
        self.dataConverted?.initializeFiltered()
        refresh()
    }
    
    func getDefaultCurrencyFromUserDefaults() -> String {
        let defaults = UserDefaults.standard
        if let defaultCurrency = defaults.string(forKey: "Currency") {
            return defaultCurrency
        }
        return "EUR"
    }
    
    func getConvertedAmountToStr(targetToEURRate: Double, numberToConvert: Double) -> Double {
        let inputToEURRate = getCurrencyDefaultValue()
        let total = numberToConvert / inputToEURRate * targetToEURRate
        return total.rounded(toPlaces: 4)
    }
    
    func getCurrencyDefaultValue() -> Double {
        let defaultCurrency = self.getDefaultCurrencyFromUserDefaults()
        if let rates = self.dataConverted?.rates {
            for rate in rates {
                if rate.currency == defaultCurrency {
                    return rate.value
                }
            }
        }
        return 0.0
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

