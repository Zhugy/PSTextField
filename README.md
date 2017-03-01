# PSTextField
> 继承PSTextField  初始 pickType 的类型 实现回调即可 实现代码如下
```python
 @IBOutlet weak var areaTF: PSTextField!
 areaTF.pickType = .address
       areaTF.cancelClose = {
            // TODO:
        }
        areaTF.sureClose = {(resource) -> Void in
            let info: [String] = resource as! [String]
            self.titleLabel.text = info.first! + info.last!
            self.areaTF.resignFirstResponder()
        }
```
![](/path/to/show.jpg)
