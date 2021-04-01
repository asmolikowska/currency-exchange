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
    var exchangeRatesData: ExchangeRatesData?
    var sections: [CurrencyCounterSection] = [.headerCounterSection, .currencies, .addMoreCurrencies]
    
    
    func getData(currency: String) {
        shouldDisplayActivityIndicator.accept(true)
        currencyApiManager.performRequest(baseCurrency: currency) {data in
            if let safeData = data {
                self.exchangeRatesData = self.currencyApiManager.parseData(exchangeRatesData: safeData)
                self.reloadLst.accept(true)
                self.shouldDisplayActivityIndicator.accept(false)
            }
        }
    }
}
