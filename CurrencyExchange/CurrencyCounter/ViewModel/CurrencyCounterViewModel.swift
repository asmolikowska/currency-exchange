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
    var exchangeRatesData: ExchangeRatesData?
    var sections: [CurrencyCounterSection] = [.headerCounterSection , .currencies, .addMoreCurrencies]
    var userStoredRatesData = UserStoredRates.userStoredRatesData
    
    func getData(currency: String) {
        shouldDisplayActivityIndicator.accept(true)
        currencyApiManager.performRequest { data in
            if let safeData = data {
                self.exchangeRatesData = self.currencyApiManager.parseData(exchangeRatesData: safeData)
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
        getUserStoredRatesData()
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
                    rateObjectEUR.rate = Rate(currency: "EUR", value: 0.0)
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
    
    func setDefaultCurrencyToUserDefaults(currency: String) {
        let defaults = UserDefaults.standard
        defaults.set(currency, forKey: "Currency")
    }
}
