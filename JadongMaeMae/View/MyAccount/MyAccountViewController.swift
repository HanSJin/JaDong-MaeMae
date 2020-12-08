//
//  MyAccountViewController.swift
//  JadongMaeMae
//
//  Created by USER on 2020/12/07.
//

import RxCocoa
import RxSwift
import UIKit

class MyAccountViewController: UIViewController {

    // Outelts
    @IBOutlet private weak var tableView: UITableView! {
        didSet { tableView.registerNib(cellIdentifier: MyAccountCell.identifier) }
    }
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var totalAccount: UILabel!
    
    // Variables
    private let accountsService: AccountsService = ServiceContainer.shared.getService(key: .accounts)
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    private var disposeBag = DisposeBag()
    
    private var accountModels: [AccountModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
}

// MARK: - Setup View
extension MyAccountViewController {
    
    func setUpView() {
        updateIpAddress()
        requestMyAccount { [weak self] accountModels in
            self?.requestCurrentPrice(accountModels: accountModels)
        }
    }
    
    private func updateIpAddress() {
        guard let url = URL(string: "https://api.ipify.org") else { return }
        let ipAddress = try? String(contentsOf: url)
        ipLabel.text = ipAddress
        print("My public IP address is: " + (ipAddress ?? "Unknown"))
    }
}

// MARK: - GlobalRunLoop
extension MyAccountViewController: GlobalRunLoop {
    
    var fps: Double { 3 }
    func runLoop() {
        requestMyAccount { [weak self] accountModels in
            self?.requestCurrentPrice(accountModels: accountModels)
        }
        totalAccount.text = NumberFormatter.decimalFormat(Int(accountModels.map { $0.currentTotalPrice }.reduce(0.0) { Double($0) + Double($1) })) + " KRW"
    }
}

// MARK: - UITableViewDataSource
extension MyAccountViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MyAccountCell = tableView.dequeueReusableCell(for: indexPath),
              let account = accountModels[safe: indexPath.row] else { return tableView.emptyCell }
        cell.updateView(account)
        return cell
    }
}

// MARK: - UITableViewDataSource
extension MyAccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Request
extension MyAccountViewController {
    
    private func requestMyAccount(completion: @escaping ([AccountModel]) -> Void) {
        accountsService.getMyAccounts().subscribe(onSuccess: {
            switch $0 {
            case .success(let accountModels):
                completion(accountModels.filter { $0.currency != "KRW" }.filter { $0.currency != "PTOY" })
            case .failure(let error):
                print(error)
            }
        }) { error in
            print(error)
        }.disposed(by: self.disposeBag)
    }
    
    private func requestCurrentPrice(accountModels: [AccountModel]) {
        quoteService.getCurrentPrice(markets: accountModels.map { "KRW-\($0.currency!)" }).subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let tickerModels):
                for accountModel in accountModels {
                    accountModel.quoteTickerModel = tickerModels.filter { $0.market == "KRW-\(accountModel.currency!)" }.first
                }
                let sortedAccoutModels = accountModels.sorted { $0.currentTotalPrice > $1.currentTotalPrice }
                self?.accountModels = sortedAccoutModels
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }) { error in
            print(error)
        }.disposed(by: self.disposeBag)
    }
}

//        quoteService.getMinuteCandle(market: "KRW-BTC", unit: 1, count: 200).subscribe {
//            switch $0 {
//            case .success(let quoteModels):
//                print(quoteModels)
//            case .failure(let error):
//                print(error)
//            }
//        } onError: {
//            print($0)
//        }.disposed(by: disposeBag)