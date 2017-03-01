# PSTextField
> 继承PSTextField  初始 pickType 的类型 实现回调即可 实现代码如下

* @IBOutlet weak var areaTF: PSTextField!
* areaTF.pickType = .address
*        areaTF.cancelClose = {
*            self.areaTF.resignFirstResponder()
*        }
*        areaTF.sureClose = {(b) -> Void in
*            let info: [String] = b as! [String]
*            self.titleLabel.text = info.first! + info.last!
*            self.areaTF.resignFirstResponder()
*        }
