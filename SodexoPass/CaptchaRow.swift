//
//  CaptchaRow.swift
//  SodexoPass
//
//  Created by Andrey Artemenko on 13/04/2017.
//  Copyright © 2017 Andrey Artemenko. All rights reserved.
//

import Foundation
import Eureka

open class CaptchaCell: Cell<String>, CellType  {
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.captchaImageView = UIImageView()
        self.captchaImageView.translatesAutoresizingMaskIntoConstraints = false
        self.captchaImageView.contentMode = .scaleAspectFit
        
        self.textField = UITextField()
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var captchaImageView: UIImageView
    public var textField: UITextField
    
    open var dynamicConstraints = [NSLayoutConstraint]()
    
    open override func setup() {
        super.setup()
        
        selectionStyle = .none
        contentView.addSubview(self.captchaImageView)
        contentView.addSubview(self.textField)
        
        setNeedsUpdateConstraints()
    }
    
    open override func update() {
        super.update()
    }

    open override func updateConstraints(){
        customConstraints()
        super.updateConstraints()
    }
    
    open func customConstraints() {
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        
        let views : [String: AnyObject] = ["captchaImageView": captchaImageView, "textField": textField]
        
        dynamicConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[captchaImageView(100)]-(15)-[textField]-|", options: [], metrics: nil, views: views))
        dynamicConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[captchaImageView]-|", options: [], metrics: nil, views: views))
        dynamicConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textField]-|", options: [], metrics: nil, views: views))
        
        contentView.addConstraints(dynamicConstraints)
    }
}

public final class CaptchaRow: Row<CaptchaCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
