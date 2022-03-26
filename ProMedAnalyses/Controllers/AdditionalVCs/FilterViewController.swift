//
//  FilterController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 09.02.2022.
//

import Foundation
import UIKit

class FilterViewController: UIViewController {
    
    private let tableForProps = UITableView()
    private let stackView = UIStackView()
    private let pickerView = UIPickerView()
    private let datePicker = UIDatePicker()
    private let textField = UITextField()
    private let formatter = DateFormatter()
    
    private let filterTypes = ["Дата", "Тип услуги", "Только патологические"]
    private let servicesTypefilter = ["","Общий (клинический) анализ крови", "Анализ крови биохимический общетерапевтический", "Ферритин", "Д-димер"]
    
    public var availiableDates = [String]()
    public var delegate: ResultsViewControllerDelegate?
    
    private var selectedDate: String?
    private var selectedTypeFilter: String?
    private var selectedPathologicalFilter: String?
    private var selectedFilter : Filter?
    
    private var selectedIndexPaths = Set<IndexPath>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Параметры фильтров"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissSelf))
        formatter.dateFormat = "dd.MM.yyyy"
        createStackView()
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFilterView()
    }
    
    @objc private func applyFilters () {
        selectedFilter = Filter(dateFilter: selectedDate, typeFilter: selectedTypeFilter, pathologicalFilter: selectedPathologicalFilter)
        self.dismiss(animated: true) {
            self.delegate?.applyFilters(using: self.selectedFilter!)
        }
    }
    
    @objc private func dismissSelf() {
        self.dismiss(animated: true) {
            self.delegate?.applyFilters(using: Filter(dateFilter: nil, typeFilter: nil, pathologicalFilter: nil))
        }
    }
    
    private func setupTableView () {
        tableForProps.register(UINib(nibName: "FilterTableCell", bundle: nil), forCellReuseIdentifier: FilterCellViewController.identifier)
        tableForProps.delegate = self
        tableForProps.dataSource = self
        view.addSubview(tableForProps)
        
        tableForProps.translatesAutoresizingMaskIntoConstraints = false
        tableForProps.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableForProps.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableForProps.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    private func setupPickerViewOnTextField () {
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .plain, target: self, action: #selector(closePickerView))
        let dummyButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([dummyButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
    }
    
    @objc private func closePickerView () {
        textField.resignFirstResponder()
    }
    
    private func createStackView () {
        let applyButton = createButton(with: "Применить", bgColor: UIColor.systemOrange, titleColor: UIColor.systemBackground, selector: #selector(applyFilters))
        
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        stackView.backgroundColor = UIColor.systemBackground
        stackView.addArrangedSubview(applyButton)
    }
    
    private func setupFilterView ()  {
        setupTableView()
        setupPickerViewOnTextField()
        stackView.topAnchor.constraint(equalTo: tableForProps.bottomAnchor).isActive = true
        tableForProps.bottomAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        view.backgroundColor = .systemBackground
        
    }
    
    @objc private func printDatePickerValue (_ sender: UIDatePicker) {
        
        let formattedDate = formatter.string(from: datePicker.date)
        selectedDate = formattedDate
        
    }
    
}

extension FilterViewController {
    
    private func createButton (with title: String, bgColor: UIColor, titleColor: UIColor, selector: Selector) -> UIButton {
        
        let button = UIButton()
        button.configuration = .bordered()
        button.backgroundColor = bgColor
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 10
        button.setTitleColor(titleColor, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCellViewController.identifier) as! FilterCellViewController
        if indexPath.row == 0 {
            cell.selectionStyle = .none
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .compact
            datePicker.minimumDate = formatter.date(from: availiableDates.first!)
            datePicker.maximumDate = formatter.date(from: availiableDates.last!)
            datePicker.addTarget(self, action: #selector(printDatePickerValue(_:)), for: .valueChanged)
            cell.configure(with: "Дата", view: datePicker)
            
        } else if indexPath.row == 1 {
            cell.selectionStyle = .none
            textField.inputView = pickerView
            textField.textAlignment = .center
            textField.backgroundColor = .opaqueSeparator.withAlphaComponent(0.3)
            textField.tintColor = .clear
            textField.layer.cornerRadius = 10
            cell.configure(with: "Тип услуги", view: textField)
        } else {
            cell.configure(with: "Только патологические")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let pathological = IndexPath(row: 2, section: 0)
        if indexPath == pathological {
            if selectedIndexPaths.contains(indexPath) {
                selectedIndexPaths.remove(indexPath)
                selectedPathologicalFilter = nil
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            } else {
                selectedIndexPaths.insert(indexPath)
                selectedPathologicalFilter = "▼"
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTypes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servicesTypefilter.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return servicesTypefilter[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = servicesTypefilter[row]
        selectedTypeFilter = servicesTypefilter[row]
    }
    
    
}

extension FilterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0, delay: 0) {
            textField.backgroundColor = .systemGray3
            textField.textColor = .systemBlue
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                textField.backgroundColor = .opaqueSeparator.withAlphaComponent(0.3)
                textField.textColor = .label
            }
        }
        
    }
    
}


