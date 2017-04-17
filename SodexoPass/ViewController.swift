//
//  ViewController.swift
//  SodexoPass
//
//  Created by Andrey Artemenko on 13/04/2017.
//  Copyright © 2017 Andrey Artemenko. All rights reserved.
//

import UIKit
import Eureka
import TesseractOCR

let cardStoreKey = "cardStoreKey"

class ViewController: FormViewController, G8TesseractDelegate {
    
    let store = UserDefaults.standard
    weak var captchaImageView: UIImageView?
    weak var captchaTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cardNumber = store.integer(forKey: cardStoreKey) as Int?
        var captchaCode: String?
        
        form +++ Section("Проверка баланса карты")
            <<< IntRow() {
                $0.title = "Номер карты"
                $0.placeholder = "Укажите номер"
                $0.add(rule: RuleRequired())
                
                if cardNumber != nil {
                    $0.value = cardNumber
                }
            }.onCellHighlightChanged({ (cell, row) in
                if !row.isHighlighted, row.value != nil {
                    cardNumber = row.value
                    self.store.set(cardNumber, forKey: cardStoreKey)
                }
            })
        
            <<< CaptchaRow() {
                self.captchaImageView = $0.cell.captchaImageView
                self.captchaTextField = $0.cell.textField
                $0.cell.textField.placeholder = "Введите символы с картинки"
            }.onCellHighlightChanged({ (cell, row) in
                if !row.isHighlighted, row.value != nil {
                    captchaCode = row.value
                }
            })
        
            <<< ButtonRow() {
                $0.title = "Проверить"
            }.onCellSelection({ (cell, row) in
                if cardNumber != nil, captchaCode != nil {
                    API.shared.checkBalance(cardNumber: "\(cardNumber!)", captchaCode: captchaCode!)
                }
            })
        
        
        API.shared.getCookie() {
            API.shared.getCaptcha() { (image) in
                if image != nil {
                    self.captchaImageView?.image = image
                    self.recognizeImage(image!)
                }
            }
        }
    }
    
    fileprivate func recognizeImage(_ image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tesseract:G8Tesseract = G8Tesseract(language:"eng")
            
            tesseract.delegate = self
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            
            DispatchQueue.main.async { // 2
                self.captchaTextField?.text = tesseract.recognizedText
            }
        }
    }

    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false; // return true if you need to interrupt tesseract before it finishes
    }
}

