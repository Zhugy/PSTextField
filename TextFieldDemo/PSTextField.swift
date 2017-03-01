//
//  PSTextField.swift
//  TextFieldDemo
//
//  Created by zhugy on 2017/2/28.
//  Copyright © 2017年 zhugy. All rights reserved.
//

import UIKit
import Cartography

class PSTextField: UITextField, UITextFieldDelegate , UIPickerViewDelegate, UIPickerViewDataSource {
    enum Gender: Int {
        case none = 0
        case male = 1
        case female = 2
    }
    
    enum PickType {
        case none
        case date
        case gender
        case address
    }
    
    var pickType: PickType = .none {
        didSet {
            switch pickType {
            case .none:
                return
            case .gender:
                createGenderPicker()
            case .date:
                createDatePicker()
            case .address:
                createGenderPicker()
            }
        }
    }
    //MARK: - 日期选择器
    private var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        datePicker.timeZone = TimeZone.init(abbreviation: "GTM+8")
        datePicker.locale = Locale.init(identifier: "zh-CN")
        datePicker.maximumDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        datePicker.minimumDate = formatter.date(from: "1900-1-1")
        datePicker.backgroundColor = UIColor.white
        return datePicker
    }()
    var userBirthdayDate: Date = Date() {
        didSet {
            datePicker.date = userBirthdayDate
        }
    }
    private var chouseDate: Date!
    //MARK: - 性别选择器初始组件
    private var pickerView: UIPickerView = {
        let pickView = UIPickerView()
        pickView.backgroundColor = UIColor.white
        return pickView
    }()
    private var chouseGender: [Gender: String] = [:]
    var items: [[Gender: String]] = [[.none: "保密"], [.male: "男"], [.female: "女"]] {
        didSet {
            if items.count > 1 {
                pickerView.selectRow(1, inComponent: 0, animated: true)
            }
            pickerView.reloadInputViews()
        }
    }
    //MARK: - 地区选择器初始控件
    private lazy var provinceArray: [[String: Any]] = {
        guard let parth = Bundle.main.path(forResource: "area", ofType: "plist") else {
            assertionFailure("can not found parth")
            return []
        }
        guard let all_dictionary = NSDictionary.init(contentsOfFile: parth) else {
            assertionFailure("can not found dictionary")
            return []
        }
        
        var province_array: [[String: Any]] = []
        for index in 0 ..< all_dictionary.count {
            guard let province_dic: [String: Any] = all_dictionary.value(forKey: "\(index)") as? Dictionary else { //一个省份的字典
                assertionFailure("can not found dict")
                return []
            }
            guard let province_key = province_dic.keys.first else { //获取这个省名字
                assertionFailure("can not found province_key")
                return []
            }
            guard let number_dic: [String: Any] = province_dic[province_key] as? Dictionary else{ //根据这个省份得到所有市的字典
                assertionFailure("can not found number_dic")
                return []
            }
            var town_array: [String] = []
            
            for count in 0 ..< number_dic.count {
                guard let town_dic: [String: Any] = number_dic["\(count)"] as? Dictionary else {
                    assertionFailure("can not found town_dic")
                    return []
                }
                guard let key: String = town_dic.keys.first else {
                    assertionFailure("not found firstKey")
                    return []
                }
                
                if number_dic.count == 1 { // 如果为直辖市 则取到 市区
                    guard let new_region = town_dic[key] as? [String] else {
                        return []
                    }
                    
                    town_array = new_region
                } else {
                    town_array.append("\(key)")
                }
                
                //                town_array.add(town_dic.allKeys[0])
            }
            let sub_dic: [String: Any] = [province_key: town_array]
            province_array.append(sub_dic)
        }
        return province_array
    }()
    private var chouseProvince: String = ""
    private var chouseCity: String = ""
    private var cityTownArray: [String] = []
    
    
    //MARK: - headToolView
    private let headView: UIView = {
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        headView.backgroundColor = UIColor.lightGray
        return headView
    }()
    private var cancelBtn: UIButton = {
        let cancelBtn = UIButton(type: UIButtonType.system)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(UIColor.black, for: .normal)
        return cancelBtn
    }()
    private var sureBtn: UIButton = {
        let sureBtn = UIButton(type: UIButtonType.system)
        sureBtn.setTitle("确定", for: .normal)
        return sureBtn
    }()
    //MARK: 回调
    var cancelClose: (() -> Void )?
    var sureClose: ((Any) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    //MARK: - 初始时间选择器
    private func createDatePicker() {
        datePicker.addTarget(self, action: #selector(chouseOneDay), for: .valueChanged)
        inputView = datePicker
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        headView.addSubview(cancelBtn)
        headView.addSubview(sureBtn)
        inputAccessoryView = headView
        setUpDatePickerLayout()
        setupHeadViewLayout()
    }
    
    private func setUpDatePickerLayout() {
        constrain(datePicker, inputView! ) { ( datePicker, textFieldInputView) in
            datePicker.top == textFieldInputView.top
            datePicker.bottom == textFieldInputView.bottom
            datePicker.left == textFieldInputView.left
            datePicker.right == textFieldInputView.right
        }
    }
    //MARK: - 性别选择器
    private func createGenderPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        inputView = pickerView
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        headView.addSubview(cancelBtn)
        headView.addSubview(sureBtn)
        inputAccessoryView = headView
        setupHeadViewLayout()
        setupGenderViewLayout()
        pickerView.reloadAllComponents()
    }
    
    private func setupGenderViewLayout() {
        constrain(pickerView, inputView!) { (pickerView, textFieldInputView) in
            pickerView.top == textFieldInputView.top
            pickerView.bottom == textFieldInputView.bottom
            pickerView.left == textFieldInputView.left
            pickerView.right == textFieldInputView.right
        }
    }
    //MARK: - headView
    private func setupHeadViewLayout() {
        constrain(cancelBtn, sureBtn, headView, inputAccessoryView!) { (cancelBtn, sureBtn, headView, textAccessoryView) in
            cancelBtn.left == headView.left + 20
            cancelBtn.top == headView.top
            cancelBtn.bottom == headView.bottom
            cancelBtn.width == headView.height
            sureBtn.right == headView.right - 20
            sureBtn.top == headView.top
            sureBtn.bottom == headView.bottom
            sureBtn.width == headView.height
        }
    }
    //MARK: - UIPickViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickType == .address {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickType == .address {
            if component == 0 {
                return provinceArray.count
            } else {
                if cityTownArray.isEmpty { // 开始加载时 cityTownArray 为空 手动取第一条数据填充
                    let subDict = provinceArray[0] as Dictionary
                    guard let subDictKey: String = subDict.keys.first else {
                        assertionFailure("can not found firstKey")
                        return 0
                    }
                    guard let new_cityTownArray = subDict["\(subDictKey)"] as? [String] else {
                        assertionFailure("can not found cityTownArray")
                        return 0
                    }
                    cityTownArray = new_cityTownArray
                }
                
                return cityTownArray.count
            }
        } else {
            return items.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickType == .address {
            if component == 0 {
                let title = (provinceArray[row] as Dictionary).keys.first
                return title
            } else {
                return cityTownArray[row]
            }
        }else {
            let dict: [Gender: String] = items[row]
            return Array(dict.values).first
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickType == .address {
            if component == 0 {
                let subDict = provinceArray[row] as Dictionary
                guard let subDictKey: String = subDict.keys.first else {
                    assertionFailure("can not found firstKey")
                    return
                }
                guard let new_cityTownArray = subDict["\(subDictKey)"] as? [String] else {
                    assertionFailure("can not found cityTownArray")
                    return
                }
                cityTownArray = new_cityTownArray // 根据选取的省 同步市的数组
                pickerView.reloadAllComponents()
                chouseProvince = subDictKey
                chouseCity = cityTownArray[0]
            } else {
                chouseCity = cityTownArray[row]
            }
            
        }else {
            chouseGender = [:]
            chouseGender = items[row]
        }
    }
    
    //MARK: - 时间选择器响应事件
    func chouseOneDay(_ datePicker: UIDatePicker) {
        chouseDate = datePicker.date
    }
    //MARK: - UIButton #selection
    @objc private func cancelBtnClick() {
        cancelClose?()
    }
    
    @objc private func sureBtnClick() {
        switch pickType {
        case .gender:
            if chouseGender.isEmpty {
                chouseGender = items[0]
            }
            sureClose?( chouseGender as [Gender: String])
        case .date:
            if chouseDate == nil {
                chouseDate = Date()
            }
            sureClose?(chouseDate as Date)
        case .address:
            if chouseProvince.isEmpty{ // 默认选取如下
                chouseProvince = "北京市"
                chouseCity = "东城区"
            }
            sureClose?(([chouseProvince, chouseCity]) as [String])
        default:
            return
        }
    }
}

