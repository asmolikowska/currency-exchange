//
//  CurrencyCounterViewModel.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 31/03/2021.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import SwiftyJSON

enum CurrencyCounterSection {
    case headerCounterSection
    case currencies
    case addMoreCurrencies
}

class CurrencyCounterViewModel: PrimaryViewModel {
    
    var shouldDisplayActivityIndicator = BehaviorRelay<Bool>(value: false)
    var showErrorMessageContent = BehaviorRelay<String?>(value: nil)
    var reloadLst = BehaviorRelay<Bool>(value: false)
    private var realm = try? Realm()
    var currencyApiManager = CurrencyApiManager()
    var dataConverted: DataConverted?
    var sections: [CurrencyCounterSection] = [.headerCounterSection , .currencies, .addMoreCurrencies]
    var userStoredRatesData = StoredRates.userStoredRatesData
    var reloadDefaultCurrencyCell = BehaviorRelay<Bool>(value: false)
    let group = DispatchGroup()
    
    func getDashboardData(completion: @escaping() -> Void) {
        shouldDisplayActivityIndicator.accept(true)
        currencyApiManager.performRequest { data in
            if let safeData = data {
                self.dataConverted = self.currencyApiManager.parsToConvertedeData(data: safeData)
                self.reloadLst.accept(true)
                self.shouldDisplayActivityIndicator.accept(false)
            }
        }
    }
    
    func getUserStoredRatesData() {
        if let realm = realm {
            userStoredRatesData = realm.objects(RateObject.self).map({ $0 })
        }
    }
    
    func refresh() {
        reloadLst.accept(true)
    }
    
    func saveCurrency(name: String) {
        getUserStoredRatesData()
        if let realm = realm {
            if !isAlreadyInDatabase(for: name) {
                try? realm.write {
                    let rateObjectEUR = RateObject()
                    rateObjectEUR.rate = Rate(currency: name, value: 0.0)
                    realm.add(rateObjectEUR)
                }
            }
        }
        refresh()
    }
    
    func isAlreadyInDatabase(for name: String) -> Bool {
        if let realm = realm {
            for object in realm.objects(RateObject.self) {
                if object.rate?.currency == name {
                    return true
                }
            }
        }
        return false
    }
    
    func deleteCurrency(object: RateObject) {
        getUserStoredRatesData()
        if let realm = realm {
            realm.beginWrite()
            realm.delete(object)
            try? realm.commitWrite()
        }
        refresh()
    }
    
    func setPrimaryCurrencies() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "IsRealmInitialized") {
            if let realm = realm {
                try? realm.write {
                    let rateObjectEUR = RateObject()
                    rateObjectEUR.rate = Rate(currency: "PLN", value: 0.0)
                    realm.add(rateObjectEUR)
                    
                    let rateObjectUSD = RateObject()
                    rateObjectUSD.rate = Rate(currency: "USD", value: 0.0)
                    realm.add(rateObjectUSD)
                    
                    let rateObjectCAD = RateObject()
                    rateObjectCAD.rate = Rate(currency: "CAD", value: 0.0)
                    realm.add(rateObjectCAD)
                    
                    let rateObjectGBP = RateObject()
                    rateObjectGBP.rate = Rate(currency: "GBP", value: 0.0)
                    realm.add(rateObjectGBP)
                }
            }
            defaults.set(true, forKey: "IsRealmInitialized")
        }
        refresh()
    }
    
    func setDefaultCurrencyToUserDefaults(currency: String?) {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "Currency") != nil {
            defaults.set(currency, forKey: "Currency")
        } else {
            defaults.set("EUR", forKey: "Currency")
        }
        self.reloadLst.accept(true)
    }
    
    func getDefaultCurrencyFromUserDefaults() -> String {
        group.enter()
        let defaults = UserDefaults.standard
        if let defaultCurrency = defaults.string(forKey: "Currency") {
            group.leave()
            return defaultCurrency
        }
        group.leave()
        return "EUR"
    }
    
    func getConvertedAmountToStr(targetToEURRate: Double, numberToConvert: Double) -> Double {
        group.enter()
        let inputToEURRate = getCurrencyDefaultValue()
        let total = numberToConvert / inputToEURRate * targetToEURRate
        group.leave()
        return total.rounded(toPlaces: 4)
    }
    
    func getCurrencyDefaultValue() -> Double {
        group.enter()
        let defaultCurrency = self.getDefaultCurrencyFromUserDefaults()
        if let rates = self.dataConverted?.rates {
            for rate in rates {
                if rate.currency == defaultCurrency {
                    return rate.value
                }
            }
        }
        group.leave()
        return 0.0
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

