//
//  ViewController.swift
//  LispMobile
//
//  Created by Sergii Puliaiev on 11/21/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import UIKit
import LispCore

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!

    let lisp = Lisp()

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = try? lisp.interpret(program: "(car '(hello b))")
        textField.delegate = self

        button .addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
    }

    func eval() {
        if let text = textField.text {
            do {
                label.text = try lisp.interpret(program: text)
            } catch let error {
                label.text = error.localizedDescription
            }
        }
    }

    @objc func pressed(sender: UIButton!) {
        eval()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        eval()
    }
}

