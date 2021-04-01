//
//  HeaderCurrencyTableViewCell.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 01/04/2021.
//

import UIKit

class HeaderCurrencyTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style , reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currencyValue: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        textField.placeholder = "Enter amount"
        textField.font = UIFont.systemFont(ofSize: 40.0)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    func setupCell() {
        self.selectionStyle = .none
        self.contentView.addSubview(currencyValue)
        NSLayoutConstraint.activate([
            currencyValue.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20.0),
            currencyValue.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
