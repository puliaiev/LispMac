//
//  ViewController.swift
//  LispMac
//
//  Created by Sergii Puliaiev on 6/16/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import Cocoa
import LispCore

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var textField: NSTextField!

    let lisp = Lisp()

    override func viewDidLoad() {
        super.viewDidLoad()

        label.stringValue = "yo"
        textField.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        label.stringValue = lisp.interpret(program: textField.stringValue)

        textField.stringValue = ""

        return true
    }
}

