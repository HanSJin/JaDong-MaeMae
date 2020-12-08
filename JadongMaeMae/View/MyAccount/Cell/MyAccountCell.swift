//
//  MyAccountCell.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

class MyAccountCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var currentPercentLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var coinUnitLabel: UILabel!
    @IBOutlet weak var avgPriceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    // Variables
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

// MARK: - Update View
extension MyAccountCell {
    
    func updateView(_ accountModel: AccountModel) {
        coinNameLabel.text = accountModel.currency
        balanceLabel.text = "\(accountModel.balanceDouble + accountModel.lockedDouble)"
        coinUnitLabel.text = accountModel.currency
        avgPriceLabel.text = "평단 \(accountModel.avgBuyPriceDouble)"
        currencyLabel.text = accountModel.unit_currency
        
        guard let quoteTickerModel = accountModel.quoteTickerModel else { return }
        currentPriceLabel.text = "\(Int(quoteTickerModel.trade_price ?? 0)) KRW"
        
        switch quoteTickerModel.changeType {
        case .EVEN: currentPriceLabel.textColor = .black
        case .FALL: currentPriceLabel.textColor = UIColor.myBlue
        case .RISE: currentPriceLabel.textColor = UIColor.myRed
        }
        
        currentAmountLabel.text = "\(NumberFormatter.decimalFormat(Int(accountModel.currentTotalPrice))) KRW"
        
        let revenueRate = ((accountModel.tradePrice / accountModel.avgBuyPriceDouble) - 1)
        currentPercentLabel.text = String(format: "%.2f", revenueRate * 100) + "%"
        
        let revenue = (accountModel.tradePrice - accountModel.avgBuyPriceDouble) * (accountModel.balanceDouble + accountModel.lockedDouble)
        revenueLabel.text = "(" + "\(NumberFormatter.decimalFormat(Int(revenue))) KRW)"
        
        if accountModel.avgBuyPriceDouble < accountModel.tradePrice {
            currentPercentLabel.textColor = UIColor.myRed
            currentAmountLabel.textColor = UIColor.myRed
            revenueLabel.textColor = UIColor.myRed
        } else {
            currentPercentLabel.textColor = UIColor.myBlue
            currentAmountLabel.textColor = UIColor.myBlue
            revenueLabel.textColor = UIColor.myBlue
        }
    }
}
