//
//  PrimaryViewModel.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 31/03/2021.
//

import Foundation
import RxCocoa

protocol PrimaryViewModel: class {
    var shouldDisplayActivityIndicator: BehaviorRelay<Bool> { get set }
    var showErrorMessageContent: BehaviorRelay<String?> { get set }
}
