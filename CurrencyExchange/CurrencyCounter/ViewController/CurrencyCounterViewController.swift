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
    var currency = "USD"
    let currencyList = UITableView()
    
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
        currencyList.delegate = self
        currencyList.dataSource = self
    }
    
    override func loadView() {
        super.loadView()
        setupCurrencyList()
    }
    
    func prepareView() {
        view.backgroundColor = .white
        currencyList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
    }
    
}

extension CurrencyCounterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch viewModel.sections[indexPath.section] {
        case .headerCounterSection:
            cell.textLabel?.text = "test"
        case .currencies:
            cell.textLabel?.text = "test2"
        }
        return cell
    }
}

