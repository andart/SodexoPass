//
//  CaptchaRow.swift
//  SodexoPass
//
//  Created by Andrey Artemenko on 13/04/2017.
//  Copyright © 2017 Andrey Artemenko. All rights reserved.
//

import Foundation
import Eureka

open class CaptchaCell: Cell<String>, CellType, UITextFieldDelegate  {
    
    public var captchaImageView: UIImageView
    public var textField: UITextField
    public var button: UIButton
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.captchaImageView = UIImageView()
        self.captchaImageView.translatesAutoresizingMaskIntoConstraints = false
        self.captchaImageView.contentMode = .scaleAspectFit
        
        self.textField = UITextField()
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        
        self.button = UIButton()
        self.button.setImage(UIImage(named: "refresh"), for: .normal)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var dynamicConstraints = [NSLayoutConstraint]()
    
    open override func setup() {
        super.setup()
        
        selectionStyle = .none
        contentView.addSubview(self.captchaImageView)
        contentView.addSubview(self.textField)
        contentView.addSubview(self.button)
        
        self.textField.addTarget(self, action: #selector(CaptchaCell.textFieldDidChange(_:)), for: .editingChanged)
        
        setNeedsUpdateConstraints()
    }
    
    deinit {
        textField.delegate = nil
        textField.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func update() {
        super.update()
        
        self.textField.delegate = self
    }

    open override func updateConstraints(){
        customConstraints()
        super.updateConstraints()
    }
    
    open func customConstraints() {
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        
        let views : [String: AnyObject] = ["captchaImageView": captchaImageView, "textField": textField, "button": self.button]
        
        dynamicConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[captchaImageView(100)]-(15)-[textField]-(15)-[button(40)]-|", options: [], metrics: nil, views: views))
        dynamicConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[captchaImageView]-|", options: [], metrics: nil, views: views))
        dynamicConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textField]-|", options: [], metrics: nil, views: views))
        dynamicConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[button]-|", options: [], metrics: nil, views: views))
        
        contentView.addConstraints(dynamicConstraints)
    }
    
    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textField.canBecomeFirstResponder
    }
    
    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        return textField.becomeFirstResponder()
    }
    
    open override func cellResignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    open func textFieldDidChange(_ textField : UITextField){
        
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        
        row.value = textValue
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
}

public final class CaptchaRow: Row<CaptchaCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
