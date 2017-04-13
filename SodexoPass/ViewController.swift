//
//  ViewController.swift
//  SodexoPass
//
//  Created by Andrey Artemenko on 13/04/2017.
//  Copyright © 2017 Andrey Artemenko. All rights reserved.
//

import UIKit
import Eureka

class ViewController: FormViewController {
    
    weak var captchaImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Проверка баланса карты")
            <<< IntRow() {
                $0.title = "Номер карты"
                $0.placeholder = "Укажите номер"  //расположенный на обратной стороне карты
                $0.add(rule: RuleRequired())
            }
        
            <<< CaptchaRow() {
                self.captchaImageView = $0.cell.captchaImageView
                $0.cell.textField.placeholder = "Введите символы с картинки"
            }
        
        
        API.shared.getCookie() {
            API.shared.getCaptcha() { (image) in
                if image != nil {
                    self.captchaImageView?.image = image
                }
            }
        }
    }


}

