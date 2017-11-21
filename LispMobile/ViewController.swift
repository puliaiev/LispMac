//
//  ViewController.swift
//  LispMobile
//
//  Created by Sergii Puliaiev on 11/21/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import UIKit
import LispCore

class ViewController: UIViewController {

    let lisp = Lisp()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        print(try? lisp.interpret(program: "(car '(a b))"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

