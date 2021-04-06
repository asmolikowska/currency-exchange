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

class CurrencyCounterViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    let viewModel: CurrencyCounterViewModel
    var disposeBag = DisposeBag()
    let currencyList = UITableView(frame: .zero, style: .grouped)
    let reuseId = "currencyCell"
    var headerCell: HeaderCurrencyTableViewCell
    var numberToConvert = BehaviorRelay<Double>(value: 1.0)
    
    
    init(viewModel: CurrencyCounterViewModel) {
        self.viewModel = viewModel
        self.headerCell = HeaderCurrencyTableViewCell(style: .value1, reuseIdentifier: "headerCell")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerCell.currencyValue.delegate = self
        bindActions()
        prepareView()
        manageKeyboard()
        viewModel.setPrimaryCurrencies()
    }
    
    func manageKeyboard() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func loadView() {
        super.loadView()
        setupCurrencyList()
        let group = DispatchGroup()
        group.enter()
        viewModel.getDashboardData() {
            group.leave()
        }
    }
    
    func prepareView() {
        view.backgroundColor = .white
        currencyList.register(CurrencyTableViewCell.self, forCellReuseIdentifier: reuseId)
        currencyList.delegate = self
        currencyList.dataSource = self
        self.title = "Currency Exchange Counter"
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
        
        
        numberToConvert.asObservable().subscribe { [unowned self] value in
            self.currencyList.reloadSections([1], with: .none)
        }.disposed(by: disposeBag)
        
        viewModel.reloadLst.asObservable().subscribe { [unowned self] shouldReload in
            if let shouldReload = shouldReload.element {
                DispatchQueue.main.async {
                    if shouldReload {
                        self.currencyList.reloadData()
                    }
                }
            }
        }.disposed(by: disposeBag)
        
        headerCell.currencyValue.rx.controlEvent([.editingChanged])
            .asObservable()
            .subscribe(onNext: { [unowned self] in
                self.numberToConvert.accept(Double(self.headerCell.currencyValue.text ?? "1") ?? 1)
            })
            .disposed(by: disposeBag)
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
            return viewModel.dataConverted?.filteredRates.count ?? 5
        case .addMoreCurrencies:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section] {
        case .headerCounterSection:
            headerCell.textLabel?.text = viewModel.getDefaultCurrencyFromUserDefaults()
            headerCell.textLabel?.font = UIFont.systemFont(ofSize: 40.0)
            return headerCell
        case .currencies:
            let cell = CurrencyTableViewCell(style: .value1, reuseIdentifier: reuseId)
            cell.textLabel?.numberOfLines = 0
            if let data = viewModel.dataConverted {
                cell.textLabel?.text =  data.filteredRates[indexPath.row].currency
                let convertedAmount = viewModel.getConvertedAmountToStr(targetToEURRate: data.filteredRates[indexPath.row].value, numberToConvert: numberToConvert.value)
                cell.detailTextLabel?.text = "\(convertedAmount)"
            }
            return cell
        case .addMoreCurrencies:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Click here to add new currency"
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.sections[indexPath.section] {
        case .addMoreCurrencies:
            self.navigationController?.pushViewController(CurrencyPickerViewController(viewModel: viewModel), animated: true)
        case .currencies:
            headerCell.textLabel?.text = currencyList.cellForRow(at: indexPath)?.textLabel?.text
            viewModel.setDefaultCurrencyToUserDefaults(currency: currencyList.cellForRow(at: indexPath)?.textLabel?.text ?? "EUR")
            currencyList.deselectRow(at: indexPath, animated: true)
        case _:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.sections[indexPath.section] {
        case .headerCounterSection:
            return 200
        case .addMoreCurrencies:
            return 70
        case _:
            return 50
        }
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            currencyList.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch viewModel.sections[indexPath.section] {
        case .currencies:
            return true
        case _:
            return false
        }
    }
}
