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
import BarcodeScanner

let cardStoreKey = "cardStoreKey"

class ViewController: FormViewController, G8TesseractDelegate, BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    
    let store = UserDefaults.standard
    weak var captchaImageView: UIImageView?
    weak var captchaTextField: UITextField?
    weak var cardNumberRow: IntRow?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cardNumber = store.object(forKey: cardStoreKey) as! Int?
        
        form +++ Section("Проверка баланса карты")
            <<< IntRow() {
                $0.title = "Номер карты"
                $0.placeholder = "Укажите номер"
                $0.add(rule: RuleRequired())
                
                self.cardNumberRow = $0
                
                if cardNumber != nil {
                    $0.value = cardNumber
                }
            }.onCellHighlightChanged({ (cell, row) in
                if !row.isHighlighted, row.value != nil {
                    cardNumber = row.value
                    self.store.set(cardNumber, forKey: cardStoreKey)
                }
            })
            
            <<< ButtonRow() {
                $0.title = "Сканировать"
                }.onCellSelection({ (cell, row) in
                    let controller = BarcodeScannerController()
                    controller.codeDelegate = self
                    controller.errorDelegate = self
                    controller.dismissalDelegate = self
                    
                    self.present(controller, animated: true, completion: nil)
                })

        
            <<< CaptchaRow() {
                self.captchaImageView = $0.cell.captchaImageView
                self.captchaTextField = $0.cell.textField
                $0.cell.textField.placeholder = "Введите символы с картинки"
                $0.cell.button.addTarget(self, action: #selector(ViewController.reloadCaptcha), for: .touchUpInside)
            }
        
            <<< ButtonRow() {
                $0.title = "Проверить"
            }.onCellSelection({ (cell, row) in
                if cardNumber != nil, let captchaCode = self.captchaTextField?.text {
                    API.shared.checkBalance(cardNumber: "\(cardNumber!)", captchaCode: captchaCode) { summ in
                        let alert = UIAlertController(title: "Доступно", message: "\((summ as! Int) / 100)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        
        
        API.shared.getCookie() {
            self.reloadCaptcha()
        }
    }
    
    func reloadCaptcha() {
        API.shared.getCaptcha() { (image) in
            if image != nil {
                self.captchaImageView?.image = image
                self.recognizeImage(image!)
            }
        }

    }
    
    fileprivate func recognizeImage(_ image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tesseract:G8Tesseract = G8Tesseract(language:"eng")
            
            tesseract.delegate = self
            tesseract.image = image.g8_grayScale()
            tesseract.recognize()
            
            DispatchQueue.main.async {
                self.captchaTextField?.text = tesseract.recognizedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        }
    }

    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false; // return true if you need to interrupt tesseract before it finishes
    }
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
         controller.dismiss(animated: true, completion: nil)
        
        self.cardNumberRow?.value = Int(code)
        self.cardNumberRow?.cell.textField.text = code
    }
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

