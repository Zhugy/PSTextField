//
//  ViewController.swift
//  TextFieldDemo
//
//  Created by zhugy on 2017/2/28.
//  Copyright © 2017年 zhugy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var areaTF: PSTextField!
    @IBOutlet weak var genderTF: PSTextField!
    @IBOutlet weak var birthdayTF: PSTextField!
    @IBOutlet weak var nicknameTF: PSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 地区
        
        areaTF.pickType = .address
        areaTF.cancelClose = {
            self.areaTF.resignFirstResponder()
        }
        areaTF.sureClose = {(b) -> Void in
            let info: [String] = b as! [String]
            self.titleLabel.text = info.first! + info.last!
            self.areaTF.resignFirstResponder()
        }
        // 性别
        genderTF.pickType = .gender
        genderTF.cancelClose = {
            self.genderTF.resignFirstResponder()
        }
        genderTF.sureClose = { b in
            let info: [PSTextField.Gender: String] = (b as? [PSTextField.Gender: String])!
            self.titleLabel.text = info.values.first
            self.genderTF.resignFirstResponder()
            
        }
        // 生日
        birthdayTF.pickType = .date
        birthdayTF.cancelClose = {
            self.birthdayTF.resignFirstResponder()
        }
        birthdayTF.sureClose = { b in
            let date = b as! Date
            let formart = DateFormatter()
            formart.dateFormat = "YYYY-MM-dd"
            self.titleLabel.text = formart.string(from: date)
            self.birthdayTF.resignFirstResponder()
        }
      
        // 默认 可不写
        nicknameTF.pickType = .none
        
        nicknameTF.delegate = self
    }
    
    // 自己实现 UITextFieldDelegate

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

