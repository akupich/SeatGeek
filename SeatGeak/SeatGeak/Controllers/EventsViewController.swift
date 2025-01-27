//
//  EventsViewController.swift
//  SeatGeek
//
//  Created by Andriy Kupich on 5/6/19.
//  Copyright © 2019 Andriy Kupich. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class EventsViewController: UIViewController, BindableViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.textField?.textColor = .white
        }
    }
    
    let disposeBag = DisposeBag()
    var viewModel: EventsViewModel!
    var dataSource: RxTableViewSectionedReloadDataSource<EventsSection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func bindViewModel() {
        viewModel.sectionsWithEvents
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        // TODO: use switch-case and display proper message for each case
        viewModel.onShowError
            .subscribeOn(MainScheduler.instance)
            .map { print ("API ERROR: \($0)") }
            .subscribe()
            .disposed(by: disposeBag)
        
        let searchInput = searchBar.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
        
        let searchClick = searchBar.rx.searchButtonClicked.map {""}
        
        Observable
            .concat(searchInput, searchClick)
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        Observable
            .of(searchBar.rx.searchButtonClicked, searchBar.rx.cancelButtonClicked)
            .merge()
            .subscribe(onNext: {
                self.searchBar?.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(EventItem.self))
            .map { indexPath, model in
                self.tableView.deselectRow(at: indexPath, animated: true)
                return model
            }
            .subscribe(onNext: {
                self.viewModel.showDetails(of: $0)
            }).disposed(by: disposeBag)
    }
    
    private func configureDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<EventsSection>(
            configureCell: { _, tableView, indexPath, item in
            if let cell = tableView.dequeueReusableCell(withIdentifier:
                EventItemTableViewCell.identifier, for: indexPath) as? EventItemTableViewCell {
                cell.configure(with: item)
                 return cell
            }
            
            return UITableViewCell()
        })
    }
}
