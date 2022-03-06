//
//  FilterController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 09.02.2022.
//

import Foundation
import UIKit

class FilterViewController: UIViewController {
    
    
    let tableForProps = UITableView()
    let stackView = UIStackView()
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    let textField = UITextField()
    let formatter = DateFormatter()
    
    let filterTypes = ["Дата", "Тип услуги", "Только патологические"]
    let servicesTypefilter = ["", "Д-димер", "Ферритин", "Общий анализ крови", "Биохимический анализ крови", "Прокальцитонин", "Общий анализ мочи", "Коагулограмма", "ЗППП"]
    var selectedTypeFilter: String?
    var selectedPathologicalFilter: String?
    var selectedFilter : Filter?
    var selectedDates = [String]()
    var availiableDates = [String]()
    var selectedIndexPaths = Set<IndexPath>()
    public var sendFilters : ((Filter?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Параметры фильтров"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissSelf))
        setupFilterView()
        formatter.dateFormat = "dd.MM.yyyy"
        
    }
    
    func configure (with dates: [String]?) {
        guard let avDates = dates else {
            return
        }
        availiableDates = avDates
    }
    
    
    @objc func applyFilters () {
        dismissSelf()
    }
    
    @objc func dismissSelf() {
        selectedFilter = Filter(dateFilter: selectedDates, typeFilter: selectedTypeFilter, pathologicalFilter: selectedPathologicalFilter)
        self.dismiss(animated: true) {
            self.sendFilters?(self.selectedFilter)
        }
    }
    
    func setupTableView () {
        tableForProps.register(UINib(nibName: "FilterTableCell", bundle: nil), forCellReuseIdentifier: "filterTableCell")
        tableForProps.delegate = self
        tableForProps.dataSource = self
        view.addSubview(tableForProps)
        
        tableForProps.translatesAutoresizingMaskIntoConstraints = false
        tableForProps.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableForProps.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableForProps.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
    }
    
    func setupPickerViewOnTextField () {
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closePickerView))
        let dummyButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([dummyButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
    }
    
    @objc func closePickerView () {
        textField.resignFirstResponder()

    }
    
    func createButton (with title: String, bgColor: UIColor, titleColor: UIColor, selector: Selector) -> UIButton {
        
        let button = UIButton()
        button.configuration = .bordered()
        button.backgroundColor = bgColor
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 10
        button.setTitleColor(titleColor, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    func createStackView () {
        let applyButton = createButton(with: "Применить", bgColor: UIColor.systemOrange, titleColor: UIColor.systemBackground, selector: #selector(applyFilters))
        
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 0
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        stackView.backgroundColor = UIColor.systemBackground
        stackView.addArrangedSubview(applyButton)
    }
    
    func setupFilterView ()  {
        setupTableView()
        createStackView()
        setupPickerViewOnTextField()
        stackView.topAnchor.constraint(equalTo: tableForProps.bottomAnchor).isActive = true
        tableForProps.bottomAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        view.backgroundColor = .systemBackground
        
    }
    
    @objc func printDatePickerValue (_ sender: UIDatePicker) {
        
        let formattedDate = formatter.string(from: datePicker.date)
        selectedDates.removeAll()
        selectedDates.append(formattedDate)
        
    }
    
  
    
    
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterTableCell") as! FilterCellViewController
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
        
        //        selectedFilters.removeAll { filter in
        //            filter.pathologicalFilter == textField.text
        //        }
        
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


