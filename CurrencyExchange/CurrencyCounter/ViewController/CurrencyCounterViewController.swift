//
//  CurrencyCounterViewController.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import UIKit
import SwiftSpinner
import RxSwift
import RxCocoa

class CurrencyCounterViewController: UIViewController, UITableViewDelegate {
    
    let viewModel: CurrencyCounterViewModel
    var disposeBag = DisposeBag()
    var defaultCurrency = "USD"
    let currencyList = UITableView()
    let reuseId = "currencyCell"
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.getData(currency: defaultCurrency)
        currencyList.reloadData()
    }
    
    override func loadView() {
        super.loadView()
        setupCurrencyList()
    }
    
    func prepareView() {
        view.backgroundColor = .white
        currencyList.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        currencyList.delegate = self
        currencyList.dataSource = self
    }
    func setupCurrencyList() {
        view.addSubview(currencyList)
        currencyList.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyList.topAnchor.constraint(equalTo: view.topAnchor),
            currencyList.leftAnchor.constraint(equalTo: view.leftAnchor),
            currencyList.rightAnchor.constraint(equalTo: view.rightAnchor),
            currencyList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        
        viewModel.reloadLst.asObservable().subscribe { shouldReload in
            if let shouldReload = shouldReload.element {
                DispatchQueue.main.async {
                    if shouldReload {
                        self.currencyList.reloadData()
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
    
}

extension CurrencyCounterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.sections[section] {
        case .headerCounterSection:
            return 1
        case .currencies:
            viewModel.exchangeRatesData?.getRates()
            return viewModel.exchangeRatesData?.rates.count ?? 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currencyList.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "PLN"
        return cell
        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.sections[indexPath.section] {
        case .headerCounterSection:
            return 200
        case _:
            return 50
        }
    }
}

