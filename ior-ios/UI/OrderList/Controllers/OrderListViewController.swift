//
//  ClientOrderListViewController.swift
//  ior-ios
//
//  Created by me on 19/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import BRYXBanner
import OneSignal

class OrderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OrderCellDelegate, UISearchBarDelegate {
    
    convenience init(favMode: Bool) {
        self.init(nibName: nil, bundle: nil)
        self.favMode = favMode
    }
    
    var sortState: [String: Bool] = [:]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var favMode: Bool = false
    var orders: [Order] = []
    var fetchedOrders: [Order] = []
    
    var startDate: TimeInterval?
    var endDate: TimeInterval?
    
    enum OrderListMode {
        case isFiltering
        case isFetching
    }
    
    var mode: OrderListMode = .isFetching
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: NSStringFromClass(OrderCell.self))
        tableView.estimatedRowHeight = 48
        return tableView
    }()
    
    lazy var viewModel: ClientOrderListViewModel = {
        var viewModel = ClientOrderListViewModel()
        return viewModel
    }()
    
    lazy var addOrderButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(add), for: .touchUpInside)
        return button
    }()
    
    lazy var pullToRefresh: UIRefreshControl = {
        var refresh = UIRefreshControl()
        self.tableView.addSubview(refresh)
        refresh.addTarget(self, action: #selector(fetchOrders), for: .valueChanged)
        return refresh
    }()
    
    override func viewDidLoad() {
        setupViews()
        setupNavigationController()
        if self.favMode == true {
            title = "Избранные"
        } else {
            title = "Заказы"
        }
        setupPush()
        
        NotificationCenter.default.addObserver(self, selector: #selector(pushReceived), name: NSNotification.Name(rawValue: "pushReceived"), object: nil)
        
        SocketsService.shared.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchOrders()
    }
    
    @objc func pushReceived() {
        fetchOrders()
    }
    
    func setupPush() {
        if Settings.pushId() == nil || Settings.pushId() == "" {
            let status = OneSignal.getPermissionSubscriptionState()
            let userId = status?.subscriptionStatus.userId ?? ""
            Settings.savePushID(id: userId)
            print("User push ID: \(userId)")
            
            viewModel.setUserPushID(push_id: userId)
        }
    }
    
    @objc func add() {
        let controller = CreateOrderViewController()
        controller.orderCreated = {
            let banner = Banner(title: "Заказ успешно создан", subtitle: "", image: nil, backgroundColor: UIColor.blue)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            self.fetchOrders()
        }
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func fetchOrders() {
        if mode == .isFetching {
            viewModel.fetchOrders { (orders) in
                if self.favMode == true {
                    self.orders = orders.filter({ $0.isFav == true }).sorted(by: { $0.updated > $1.updated })
                    self.fetchedOrders = orders.filter({ $0.isFav == true }).sorted(by: { $0.updated > $1.updated })
                } else {
                    self.orders = orders.sorted(by: { $0.updated > $1.updated })
                    self.fetchedOrders = orders.sorted(by: { $0.updated > $1.updated })
                }
                SocketsService.shared.subscribe(withOrders: self.orders)
                self.pullToRefresh.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        orders = orders.filter({$0.number.contains(searchText)})
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        orders = fetchedOrders
        tableView.reloadData()
    }
    
    @objc func searchDidTapped(_ sender: UIButton) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        self.present(searchController, animated: true, completion: nil)
    }
    
    @objc func filterDidTapped(_ sender: UIButton) {
        let controller = SortViewController()
        controller.rawStartDate = startDate ?? nil
        controller.rawEndDate = endDate ?? nil
        controller.sortByType = {
            self.mode = .isFiltering
            if let key = self.sortState["type"] {
                if key == true {
                    self.sortState["type"] = false
                    self.orders = self.fetchedOrders.sorted(by: { $0.type.name < $1.type.name })
                    self.tableView.reloadData()
                } else {
                    self.sortState["type"] = true
                    self.orders = self.fetchedOrders.sorted(by: { $0.type.name > $1.type.name })
                    self.tableView.reloadData()
                }
            } else {
                self.sortState["type"] = true
                self.orders = self.fetchedOrders.sorted(by: { $0.type.name > $1.type.name })
                self.tableView.reloadData()
            }
            
            
        }
        controller.sortByUser = {
            self.mode = .isFiltering
            
            if (Settings.userType() == .Client) {
                if let key = self.sortState["user"] {
                    if key == true {
                        self.sortState["user"] = false
                        self.orders = self.fetchedOrders.sorted(by: { $0.responsible < $1.responsible })
                        self.tableView.reloadData()
                    } else {
                        self.sortState["user"] = true
                        self.orders = self.fetchedOrders.sorted(by: { $0.responsible > $1.responsible })
                        self.tableView.reloadData()
                    }
                } else {
                    self.sortState["user"] = true
                    self.orders = self.fetchedOrders.sorted(by: { $0.responsible > $1.responsible })
                    self.tableView.reloadData()
                }
            } else {
                if let key = self.sortState["user"] {
                    if key == true {
                        self.sortState["user"] = false
                        self.orders = self.fetchedOrders.sorted(by: { $0.client.name < $1.client.name })
                        self.tableView.reloadData()
                    } else {
                        self.sortState["user"] = true
                        self.orders = self.fetchedOrders.sorted(by: { $0.client.name > $1.client.name })
                        self.tableView.reloadData()
                    }
                } else {
                    self.sortState["user"] = true
                    self.orders = self.fetchedOrders.sorted(by: { $0.client.name > $1.client.name })
                    self.tableView.reloadData()
                }
            }
            
            
            
            
        }
        controller.sortByStatus = {
            self.mode = .isFiltering
            if let key = self.sortState["status"] {
                if key == true {
                    self.sortState["status"] = false
                    self.orders = self.fetchedOrders.sorted(by: { $0.currentstatus < $1.currentstatus })
                    self.tableView.reloadData()
                } else {
                    self.sortState["status"] = true
                    self.orders = self.fetchedOrders.sorted(by: { $0.currentstatus > $1.currentstatus })
                    self.tableView.reloadData()
                }
            } else {
                self.sortState["status"] = true
                self.orders = self.fetchedOrders.sorted(by: { $0.currentstatus > $1.currentstatus })
                self.tableView.reloadData()
            }
            
        }
        controller.filterWithStartDate = { (startDate) in
            self.mode = .isFiltering
            self.startDate = startDate
            self.orders = self.fetchedOrders.filter({ $0.date / 1000 > startDate})
            self.tableView.reloadData()
        }
        controller.filterWithBothDates = { (startDate, endDate) in
            self.mode = .isFiltering
            self.startDate = startDate
            self.endDate = endDate
            self.orders = self.fetchedOrders.filter({ $0.date / 1000 > startDate && $0.date / 1000 < endDate})
            self.tableView.reloadData()
        }
        controller.clear = {
            self.sortState.removeAll()
            self.mode = .isFetching
            self.orders = self.fetchedOrders
            self.startDate = nil
            self.endDate = nil
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func setupNavigationController() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchDidTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(filterDidTapped(_:)))
    }
    
    func favDidTapped(isFav: Bool, index: Int) {
        self.mode = .isFetching
        if isFav {
            viewModel.addToFav(_id: Settings.userId() ?? "", order_id: orders[index]._id, completion: {
                self.fetchOrders()
            })
        } else {
            viewModel.removeFromFav(_id: Settings.userId() ?? "", order_id: orders[index]._id, completion: {
                self.fetchOrders()
            })
        }
    }
    
    func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ make in
            make.edges.equalTo(self.view)
        })
        
        view.addSubview(addOrderButton)
        addOrderButton.snp.makeConstraints({ make in
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.bottom.equalTo(self.view.snp.bottom).offset(-90)
        })
    }
    
}
extension OrderListViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(OrderCell.self), for: indexPath) as? OrderCell else { return UITableViewCell()}
        cell.order = orders[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.delegate = self
        cell.index = indexPath.row
        
        if let seenOrder = UserDefaults.standard.value(forKey: "seenOrder") as? String {
            if seenOrder.contains("\(orders[indexPath.row]._id)-\(String(orders[indexPath.row].updated))") == false {
                cell.backgroundColor = UIColor.green.withAlphaComponent(0.2)
            }
        } else {
            cell.backgroundColor = UIColor.green.withAlphaComponent(0.2)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mode = .isFetching
        let controller = OrderViewController()
        controller.order = orders[indexPath.row]
        controller.completion = {
            let banner = Banner(title: "Заказ успешно обновлен", subtitle: "", image: nil, backgroundColor: UIColor.blue)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            self.fetchOrders()
        }
        
        controller.discussionCompletion = {
            let banner = Banner(title: "Сообщение успешно отправлено", subtitle: "", image: nil, backgroundColor: UIColor.blue)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }
        
        if let seenOrder = UserDefaults.standard.value(forKey: "seenOrder") as? String {
            let result = seenOrder + " " + orders[indexPath.row]._id + "-" + String(orders[indexPath.row].updated)
            UserDefaults.standard.set(result, forKey: "seenOrder")
        } else {
            let result = orders[indexPath.row]._id + "-" + String(orders[indexPath.row].updated)
            UserDefaults.standard.set(result, forKey: "seenOrder")
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

protocol OrderCellDelegate: class {
    func favDidTapped(isFav: Bool, index: Int)
}

class OrderCell: UITableViewCell {
    
    weak var delegate: OrderCellDelegate?
    
    var order: Order? {
        didSet {
            guard let order = order else { return }
            self.number.text = order.number
            self.date.text = Date(timeIntervalSince1970: order.date / 1000).formattedDate()
            self.updated.text = Date(timeIntervalSince1970: order.updated / 1000).formattedDate()
            self.type.text = String(order.type.name)
            
            self.status.text = order.currentstatus
            
            if let name = order.assignedTo {
                self.user.text = name.name
            } else {
                self.user.text = order.assignedToGroup?.name ?? ""
            }
            
            guard let isFav = order.isFav else { return }
            if isFav {
                fav = true
                favButton.setImage(UIImage(named: "star-filled"), for: .normal)
            } else {
                fav = false
                favButton.setImage(UIImage(named: "star"), for: .normal)
            }
        }
    }
    
    var fav: Bool = false
    var index: Int = 0
    
    lazy var favButton: UIButton = {
        var button = UIButton(type: .system)
        if self.fav == false {
            button.setImage(UIImage(named: "star"), for: .normal)
        } else if self.fav == true {
            button.setImage(UIImage(named: "star-filled"), for: .normal)
        }
        button.tintColor = .black
        button.addTarget(self, action: #selector(favDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    override func prepareForReuse() {
        favButton.setImage(UIImage(named: "star"), for: .normal)
        backgroundColor = .white
    }
    
    lazy var number: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var numberLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Номер"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Создан"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var date: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var updatedLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Обновлен"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var updated: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var typeLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Тип"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var type: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var userLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Исполнитель"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var user: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var statusLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Статус"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var status: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func favDidTapped(_ sender: UIButton) {
        if fav == true {
            fav = false
            favButton.setImage(UIImage(named: "star"), for: .normal)
        } else {
            fav = true
            favButton.setImage(UIImage(named: "star-filled"), for: .normal)
        }
        delegate?.favDidTapped(isFav: fav, index: index)
    }
    
    func setupViews() {
        
        selectionStyle = .none
        
        addSubview(number)
        addSubview(date)
        addSubview(updated)
        addSubview(type)
        addSubview(user)
        addSubview(numberLabel)
        addSubview(dateLabel)
        addSubview(updatedLabel)
        addSubview(typeLabel)
        addSubview(userLabel)
        addSubview(status)
        addSubview(statusLabel)
        addSubview(favButton)
        
        favButton.snp.makeConstraints({ make in
            make.top.equalTo(self.snp.top).offset(10)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(30)
            make.width.equalTo(30)
        })
        
        numberLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.snp.top).offset(50)
        })
        
        number.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-40)
            make.top.equalTo(self.snp.top).offset(50)
        })
        
        statusLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.number.snp.bottom).offset(10)
        })
        
        status.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-40)
            make.top.equalTo(self.number.snp.bottom).offset(10)
        })
        
        dateLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.status.snp.bottom).offset(10)
        })
        
        date.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-40)
            make.top.equalTo(self.status.snp.bottom).offset(10)
        })
        
        updatedLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.date.snp.bottom).offset(10)
        })
        
        updated.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-40)
            make.top.equalTo(self.date.snp.bottom).offset(10)
        })
        
        typeLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.updated.snp.bottom).offset(10)
        })
        
        type.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-40)
            make.top.equalTo(self.updated.snp.bottom).offset(10)
        })
        
        userLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.type.snp.bottom).offset(10)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        })
        
        user.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-40)
            make.top.equalTo(self.type.snp.bottom).offset(10)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        })
    }
}
