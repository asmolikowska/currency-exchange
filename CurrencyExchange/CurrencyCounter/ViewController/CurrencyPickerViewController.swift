//
//  CurrencyPickerViewController.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 01/04/2021.
//


import UIKit
import SwiftSpinner
import RxSwift
import RxCocoa

class CurrencyPickerViewController: UIViewController, UITableViewDelegate {
    
    let viewModel: CurrencyPickerViewModel
    var disposeBag = DisposeBag()
    var defaultCurrency = "USD"
    let currencyList = UITableView()
    let reuseId = "currencyCell"
    
    
    init(viewModel: CurrencyPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getData(currency: defaultCurrency)
        bindActions()
        prepareView()
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

extension CurrencyPickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.exchangeRatesData?.getRates().count ?? 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currencyList.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        if let exchange = viewModel.exchangeRatesData {
            cell.textLabel?.text =  exchange.getRates()[indexPath.row].currency
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.popViewController(animated: true)
    }
}

