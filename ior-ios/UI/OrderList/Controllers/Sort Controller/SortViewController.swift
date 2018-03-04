//
//  SortViewController.swift
//  ior-ios
//
//  Created by me on 24/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit

class SortViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sortByType: (() -> ())?
    var sortByStatus: (() -> ())?
    var sortByUser: (() -> ())?
    var clear: (() -> ())?
    
    var filterWithStartDate: ((TimeInterval) -> ())?
    var filterWithBothDates: ((TimeInterval, TimeInterval) -> ())?
    
    var startDate: String?
    var endDate: String?
    var rawStartDate: TimeInterval? {
        didSet {
            guard let rawStartDate = rawStartDate else { return }
            startDate = Date.init(timeIntervalSince1970: rawStartDate).formattedDateWithoutHours()
        }
    }
    var rawEndDate: TimeInterval? {
        didSet {
            guard let rawEndDate = rawEndDate else { return }
            endDate = Date.init(timeIntervalSince1970: rawEndDate).formattedDateWithoutHours()
        }
    }
    
    lazy var segmentControlView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 0.6)
        return view
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        var items = ["Статус", "Тип", "Исполнитель"]
        let view = UISegmentedControl(items: items)
        view.addTarget(self, action: #selector(segmentedControlHandler(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var segmentControlViewBorder: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        return view
    }()
    
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.register(TextCell.self, forCellReuseIdentifier: NSStringFromClass(TextCell.self))
        return tableView
    }()
    
    lazy var filterButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Фильтровать", for: .normal)
        button.addTarget(self, action: #selector(filterDidTapped(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        if startDate != nil {
            filterButton.isHidden = false
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.navigationController?.navigationBar.shadowImage = nil
        }
    }
    
    @objc func filterDidTapped(_ sender: UIButton) {
        if rawEndDate != nil {
            guard let filterWithBothDates = filterWithBothDates, let rawStartDate = rawStartDate, let rawEndDate = rawEndDate else { return }
            filterWithBothDates(rawStartDate.startOfDay(), rawEndDate.endOfDay())
        } else {
            guard let filterWithStartDate = filterWithStartDate, let rawStartDate = rawStartDate else { return }
            filterWithStartDate(rawStartDate.startOfDay())
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func clearDidTapped(_ sender: UIButton) {
        guard let clear = clear else { return }
        self.startDate = nil
        self.endDate = nil
        self.tableView.reloadData()
        self.filterButton.isHidden = true
        clear()
    }
    
    @objc func segmentedControlHandler(_ sender: UISegmentedControl) {
        guard let sortByType = sortByType, let sortByStatus = sortByStatus, let sortByUser = sortByUser else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            sortByStatus()
            navigationController?.popViewController(animated: true)
        case 1:
            sortByType()
            navigationController?.popViewController(animated: true)
        case 2:
            sortByUser()
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if startDate == nil {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath) as? UITableViewCell else { return UITableViewCell() }
                cell.textLabel?.text = "Дата начала"
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
                cell.textLabel?.text = "Дата начала"
                cell.detailTextLabel?.text = startDate
                return cell
            }
        } else if endDate == nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath) as? UITableViewCell else { return UITableViewCell() }
            cell.textLabel?.text = "Дата окончания"
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
            cell.textLabel?.text = "Дата окончания"
            cell.detailTextLabel?.text = endDate
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let controller = DatePickerViewController(_id: "", value: "", mode: .DateFilter, title: "Дата начала", completion: { (rawDate, value) in
                self.startDate = value
                self.rawStartDate = TimeInterval(rawDate)
                self.tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = DatePickerViewController(_id: "", value: "", mode: .DateFilter, title: "Дата окончания", completion: { (rawDate, value) in
                self.endDate = value
                self.rawEndDate = TimeInterval(rawDate)
                self.tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func setupViews() {
        title = "Сортировка"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Очистить", style: .plain, target: self, action:  #selector(clearDidTapped(_:)))
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(segmentControlView)
        view.addSubview(filterButton)
        segmentControlView.addSubview(segmentedControl)
        segmentControlView.addSubview(segmentControlViewBorder)
        
        tableView.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.segmentControlView.snp.bottom)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        segmentControlView.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.view.snp.top).offset(64)
            make.height.equalTo(80)
        })
        
        segmentedControl.snp.makeConstraints({ make in
            make.left.equalTo(self.segmentControlView.snp.left).offset(20)
            make.right.equalTo(self.segmentControlView.snp.right).offset(-20)
            make.centerY.equalTo(self.segmentControlView.snp.centerY)
        })
        
        segmentControlViewBorder.snp.makeConstraints({ make in
            make.left.equalTo(self.segmentControlView.snp.left).offset(0)
            make.right.equalTo(self.segmentControlView.snp.right).offset(0)
            make.bottom.equalTo(self.segmentControlView.snp.bottom).offset(0)
            make.height.equalTo(1)
        })
        
        filterButton.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.height.equalTo(60)
        })
    }
}
