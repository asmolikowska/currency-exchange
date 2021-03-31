//
//  CurrencyCounterViewController.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import UIKit
import SwiftSpinner
import RxCocoa
import RxSwift


class CurrencyCounterViewController: UIViewController {
    
    let viewModel: CurrencyCounterViewModel
    var disposeBag = DisposeBag()
    var currency = "USD"
    
    init(viewModel: CurrencyCounterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindActions()
        prepareView()
        viewModel.getData(currency: currency)
    }
    
    func prepareView() {
        view.backgroundColor = .white
    }
    
    func bindActions() {
        viewModel.shouldDisplayActivityIndicator.asObservable().subscribe { shouldShow in
            if let shouldShow = shouldShow.element {
                DispatchQueue.main.async {
                    if shouldShow {
                        SwiftSpinner.show("Loading")
                    } else {
                        SwiftSpinner.hide()
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
    
}

