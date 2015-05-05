//
//  KeyboardViewController.swift
//  Custom Keyboard
//
//  Created by Paul Cohn on 5/2/15.
//  Copyright (c) 2015 Paul Cohn. All rights reserved.
//

import UIKit

class UIButtonTypeCustom : UIButton {
    
}

class KeyboardViewController: UIInputViewController {
    
    var keyboardView: UIView!
    var toggle = false
    var symbols = false
    var caps = false
    var holding = false
    var holdingKey = "abcd"
    var holdingHasPressed = false
    var pressed = "abcd"
    var tappedBlank = false
    var pan: UIPanGestureRecognizer!
//    var hold: UILongPressGestureRecognizer!
    var views = [
        "letters": ["abcd","efgh","ijkl", "mnop", "qrst", "uvwx", "yz.,", "?!⏎#"],
        "symbols": ["123456", "7890<>", "{}\"@", "#$%^", "-_=+`~", "&*()", "/:;'", "\\[]|a"],
        "caps": ["ABCD","EFGH","IJKL", "MNOP", "QRST", "UVWX", "YZ.,", "?!⏎#"]
    ]

    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var button5: UIButton!
    @IBOutlet var button6: UIButton!
    @IBOutlet var button7: UIButton!
    @IBOutlet var button8: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.setAnimationsEnabled(false)
        pan = UIPanGestureRecognizer(target: self, action: "respondToPan:")
//        swipeRight.cancelsTouchesInView = true
//        swipeRight.delaysTouchesBegan = true
        self.view.addGestureRecognizer(pan)
//
//        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipe:")
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
//        self.view.addGestureRecognizer(swipeLeft)
//        
//        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipe:")
//        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
//        self.view.addGestureRecognizer(swipeDown)
        
//        var hold = UILongPressGestureRecognizer(target: self, action: "holdHandler:")
//        hold.minimumPressDuration = 0.2
//        self.view.addGestureRecognizer(hold)

        self.loadInterface()
    }
    
    func loadInterface() {
        var keyboardNib = UINib(nibName: "KeyboardView", bundle: nil)
        self.keyboardView = keyboardNib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.addSubview(self.keyboardView)
        view.backgroundColor = self.keyboardView.backgroundColor
        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
    }
    
    @IBAction func touchDown(sender: UIButton) {
        self.pressed = sender.titleForState(.Normal)!
        if count(self.pressed) > 1 {
            self.holding = true
            self.holdingKey = self.pressed
            if self.symbols {
                updateNumbers()
            } else if self.caps {
                updateCaps()
            } else {
                updateLetters()
            }
        }
        if self.pressed == "" {
            self.tappedBlank = true
        }
    }

    @IBAction func buttonPressed(sender: UIButton) {
        let title = sender.titleForState(.Normal)!
        if title == "" {
            if self.holdingHasPressed {
                resetKeys()
            }
            if self.tappedBlank {
                self.tappedBlank = false
                resetKeys()
            }
            self.holding = false
            self.holdingHasPressed = false
            pan.enabled = true
        } else {
            if title == "123!@#" {
                resetNumbers()
                self.symbols = true
            } else if title == "abc" {
                resetLetters()
                self.symbols = false
            } else if count(title) == 1 {
                var proxy = textDocumentProxy as! UITextDocumentProxy
                if title == "⏎" {
                    proxy.insertText("\n")
                } else {
                    proxy.insertText(title)
                }
                if self.holding {
                    self.holdingHasPressed = true
                } else {
                    resetKeys()
                }
            }
        }
        if self.holdingHasPressed {
            pan.enabled = false
        }
    }
    
    func respondToPan(gesture: UIPanGestureRecognizer) {
//        hold = UILongPressGestureRecognizer(target: self, action: "holdHandler:")
//        hold.minimumPressDuration = 0.2
        if gesture.state == UIGestureRecognizerState.Began {
            resetKeys()
//            self.view.addGestureRecognizer(hold)
        }
        if gesture.state == UIGestureRecognizerState.Ended {
            var velocity = gesture.velocityInView(self.view)
            if velocity.y > 0 && abs(velocity.y) > abs(velocity.x) {
                // swipe down
                if self.symbols {
                    resetLetters()
                    self.symbols = false
                    self.caps = false
                } else if self.caps {
                    resetNumbers()
                    self.symbols = true
                    self.caps = false
                } else {
                    resetCaps()
                    self.symbols = false
                    self.caps = true
                }
            } else if velocity.y < 0 && abs(velocity.y) > abs(velocity.x) {
                // swipe up
                if self.symbols {
                    resetCaps()
                    self.caps = true
                    self.symbols = false
                } else if self.caps {
                    resetLetters()
                    self.caps = false
                    self.symbols = false
                } else {
                    resetNumbers()
                    self.symbols = true
                    self.caps = false
                }
            } else if velocity.x > 0 {
                var proxy = textDocumentProxy as! UITextDocumentProxy
                proxy.insertText(" ")
            } else if velocity.x < 0 {
                var proxy = textDocumentProxy as! UITextDocumentProxy
                proxy.deleteBackward()
            }
//            self.view.removeGestureRecognizer(hold)
        }

    }
    
//    func respondToSwipe(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizerDirection.Right:
//                var proxy = textDocumentProxy as! UITextDocumentProxy
//                proxy.insertText(" ")
//            case UISwipeGestureRecognizerDirection.Left:
//                var proxy = textDocumentProxy as! UITextDocumentProxy
//                proxy.deleteBackward()
//            case UISwipeGestureRecognizerDirection.Down:
//                var proxy = textDocumentProxy as! UITextDocumentProxy
//                proxy.insertText(". ")
//            default:
//                break
//            }
//        }
//    }
    
    func holdHandler(gesture: UIGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.Ended {
            var proxy = textDocumentProxy as! UITextDocumentProxy
            proxy.insertText(" ")
        }
    }
    
    func resetKeys() {
        if self.symbols {
            resetNumbers()
        } else if self.caps {
            resetCaps()
        } else {
            resetLetters()
        }
    }
    
    func updateLetters() {
        for (index, set) in enumerate(self.views["letters"]!) {
            if self.pressed == set {
                if index < 4 {
                    setBlank1234()
                    self.button5.setTitle(String(set[advance(set.startIndex, 0)]), forState: .Normal)
                    self.button6.setTitle(String(set[advance(set.startIndex, 1)]), forState: .Normal)
                    self.button7.setTitle(String(set[advance(set.startIndex, 2)]), forState: .Normal)
                    self.button8.setTitle(String(set[advance(set.startIndex, 3)]), forState: .Normal)
                } else {
                    setBlank5678()
                    self.button1.setTitle(String(set[advance(set.startIndex, 0)]), forState: .Normal)
                    self.button2.setTitle(String(set[advance(set.startIndex, 1)]), forState: .Normal)
                    self.button3.setTitle(String(set[advance(set.startIndex, 2)]), forState: .Normal)
                    self.button4.setTitle(String(set[advance(set.startIndex, 3)]), forState: .Normal)
                }
                break
            }
        }
//        if self.pressed == "abcd" {
//            setBlank1234()
//            self.button5.setTitle("a", forState: .Normal)
//            self.button6.setTitle("b", forState: .Normal)
//            self.button7.setTitle("c", forState: .Normal)
//            self.button8.setTitle("d", forState: .Normal)
//        } else if self.pressed == "efgh" {
//            setBlank1234()
//            self.button5.setTitle("e", forState: .Normal)
//            self.button6.setTitle("f", forState: .Normal)
//            self.button7.setTitle("g", forState: .Normal)
//            self.button8.setTitle("h", forState: .Normal)
//        } else if self.pressed == "ijkl" {
//            setBlank1234()
//            self.button5.setTitle("i", forState: .Normal)
//            self.button6.setTitle("j", forState: .Normal)
//            self.button7.setTitle("k", forState: .Normal)
//            self.button8.setTitle("l", forState: .Normal)
//        } else if self.pressed == "mnop" {
//            setBlank1234()
//            self.button5.setTitle("m", forState: .Normal)
//            self.button6.setTitle("n", forState: .Normal)
//            self.button7.setTitle("o", forState: .Normal)
//            self.button8.setTitle("p", forState: .Normal)
//        } else if self.pressed == "qrst" {
//            self.button1.setTitle("q", forState: .Normal)
//            self.button2.setTitle("r", forState: .Normal)
//            self.button3.setTitle("s", forState: .Normal)
//            self.button4.setTitle("t", forState: .Normal)
//            setBlank5678()
//        } else if self.pressed == "uvwx" {
//            self.button1.setTitle("u", forState: .Normal)
//            self.button2.setTitle("v", forState: .Normal)
//            self.button3.setTitle("w", forState: .Normal)
//            self.button4.setTitle("x", forState: .Normal)
//            setBlank5678()
//        } else if self.pressed == "yz.," {
//            self.button1.setTitle("y", forState: .Normal)
//            self.button2.setTitle("z", forState: .Normal)
//            self.button3.setTitle(".", forState: .Normal)
//            self.button4.setTitle(",", forState: .Normal)
//            setBlank5678()
//        } else if self.pressed == "?!⏎#" {
//            self.button1.setTitle("?", forState: .Normal)
//            self.button2.setTitle("!", forState: .Normal)
//            self.button3.setTitle("⏎", forState: .Normal)
//            self.button4.setTitle("123!@#", forState: .Normal)
//            setBlank5678()
//        }
    }
    
    func updateCaps() {
        if self.pressed == "ABCD" {
            setBlank1234()
            self.button5.setTitle("A", forState: .Normal)
            self.button6.setTitle("B", forState: .Normal)
            self.button7.setTitle("C", forState: .Normal)
            self.button8.setTitle("D", forState: .Normal)
        } else if self.pressed == "EFGH" {
            setBlank1234()
            self.button5.setTitle("E", forState: .Normal)
            self.button6.setTitle("F", forState: .Normal)
            self.button7.setTitle("G", forState: .Normal)
            self.button8.setTitle("H", forState: .Normal)
        } else if self.pressed == "IJKL" {
            setBlank1234()
            self.button5.setTitle("I", forState: .Normal)
            self.button6.setTitle("J", forState: .Normal)
            self.button7.setTitle("K", forState: .Normal)
            self.button8.setTitle("L", forState: .Normal)
        } else if self.pressed == "MNOP" {
            setBlank1234()
            self.button5.setTitle("M", forState: .Normal)
            self.button6.setTitle("N", forState: .Normal)
            self.button7.setTitle("O", forState: .Normal)
            self.button8.setTitle("P", forState: .Normal)
        } else if self.pressed == "QRST" {
            self.button1.setTitle("Q", forState: .Normal)
            self.button2.setTitle("R", forState: .Normal)
            self.button3.setTitle("S", forState: .Normal)
            self.button4.setTitle("T", forState: .Normal)
            setBlank5678()
        } else if self.pressed == "UVWX" {
            self.button1.setTitle("U", forState: .Normal)
            self.button2.setTitle("V", forState: .Normal)
            self.button3.setTitle("W", forState: .Normal)
            self.button4.setTitle("X", forState: .Normal)
            setBlank5678()
        } else if self.pressed == "YZ.," {
            self.button1.setTitle("Y", forState: .Normal)
            self.button2.setTitle("Z", forState: .Normal)
            self.button3.setTitle(".", forState: .Normal)
            self.button4.setTitle(",", forState: .Normal)
            setBlank5678()
        } else if self.pressed == "?!⏎#" {
            self.button1.setTitle("?", forState: .Normal)
            self.button2.setTitle("!", forState: .Normal)
            self.button3.setTitle("⏎", forState: .Normal)
            self.button4.setTitle("123!@#", forState: .Normal)
            setBlank5678()
        }
    }
    
    func updateNumbers() {
        if self.pressed == "123456" {
            self.button1.setTitle("", forState: .Normal)
            self.button2.setTitle("1", forState: .Normal)
            self.button3.setTitle("", forState: .Normal)
            self.button4.setTitle("4", forState: .Normal)
            self.button5.setTitle("2", forState: .Normal)
            self.button6.setTitle("3", forState: .Normal)
            self.button7.setTitle("5", forState: .Normal)
            self.button8.setTitle("6", forState: .Normal)
        } else if self.pressed == "7890<>" {
            self.button1.setTitle("", forState: .Normal)
            self.button2.setTitle("7", forState: .Normal)
            self.button3.setTitle("", forState: .Normal)
            self.button4.setTitle("0", forState: .Normal)
            self.button5.setTitle("8", forState: .Normal)
            self.button6.setTitle("9", forState: .Normal)
            self.button7.setTitle("<", forState: .Normal)
            self.button8.setTitle(">", forState: .Normal)
        } else if self.pressed == "{}\"@" {
            setBlank1234()
            self.button5.setTitle("{", forState: .Normal)
            self.button6.setTitle("}", forState: .Normal)
            self.button7.setTitle("\"", forState: .Normal)
            self.button8.setTitle("@", forState: .Normal)
        } else if self.pressed == "#$%^" {
            setBlank1234()
            self.button5.setTitle("#", forState: .Normal)
            self.button6.setTitle("$", forState: .Normal)
            self.button7.setTitle("%", forState: .Normal)
            self.button8.setTitle("^", forState: .Normal)
        } else if self.pressed == "&*()" {
            self.button1.setTitle("&", forState: .Normal)
            self.button2.setTitle("*", forState: .Normal)
            self.button3.setTitle("(", forState: .Normal)
            self.button4.setTitle(")", forState: .Normal)
            setBlank5678()
        } else if self.pressed == "-_=+`~" {
            self.button1.setTitle("-", forState: .Normal)
            self.button2.setTitle("_", forState: .Normal)
            self.button3.setTitle("=", forState: .Normal)
            self.button4.setTitle("+", forState: .Normal)
            self.button5.setTitle("`", forState: .Normal)
            self.button6.setTitle("", forState: .Normal)
            self.button7.setTitle("~", forState: .Normal)
            self.button8.setTitle("", forState: .Normal)
        } else if self.pressed == "/:;'" {
            self.button1.setTitle("/", forState: .Normal)
            self.button2.setTitle(":", forState: .Normal)
            self.button3.setTitle(";", forState: .Normal)
            self.button4.setTitle("'", forState: .Normal)
            setBlank5678()
        } else if self.pressed == "\\[]|a" {
            self.button1.setTitle("\\", forState: .Normal)
            self.button2.setTitle("[", forState: .Normal)
            self.button3.setTitle("]", forState: .Normal)
            self.button4.setTitle("abc", forState: .Normal)
            self.button5.setTitle("|", forState: .Normal)
            self.button6.setTitle("", forState: .Normal)
            self.button7.setTitle("", forState: .Normal)
            self.button8.setTitle("", forState: .Normal)
        }
    }
    
    func resetLetters() {
        self.button1.setTitle("abcd", forState: .Normal)
        self.button2.setTitle("efgh", forState: .Normal)
        self.button3.setTitle("ijkl", forState: .Normal)
        self.button4.setTitle("mnop", forState: .Normal)
        self.button5.setTitle("qrst", forState: .Normal)
        self.button6.setTitle("uvwx", forState: .Normal)
        self.button7.setTitle("yz.,", forState: .Normal)
        self.button8.setTitle("?!⏎#", forState: .Normal)
    }
    
    func resetCaps() {
        self.button1.setTitle("ABCD", forState: .Normal)
        self.button2.setTitle("EFGH", forState: .Normal)
        self.button3.setTitle("IJKL", forState: .Normal)
        self.button4.setTitle("MNOP", forState: .Normal)
        self.button5.setTitle("QRST", forState: .Normal)
        self.button6.setTitle("UVWX", forState: .Normal)
        self.button7.setTitle("YZ.,", forState: .Normal)
        self.button8.setTitle("?!⏎#", forState: .Normal)
    }
    
    func resetNumbers() {
        self.button1.setTitle("123456", forState: .Normal)
        self.button2.setTitle("{}\"@", forState: .Normal)
        self.button3.setTitle("7890<>", forState: .Normal)
        self.button4.setTitle("#$%^", forState: .Normal)
        self.button5.setTitle("&*()", forState: .Normal)
        self.button6.setTitle("-_=+`~", forState: .Normal)
        self.button7.setTitle("/:;'", forState: .Normal)
        self.button8.setTitle("\\[]|a", forState: .Normal)
    }
    
    func setBlank1234() {
        self.button1.setTitle("", forState: .Normal)
        self.button2.setTitle("", forState: .Normal)
        self.button3.setTitle("", forState: .Normal)
        self.button4.setTitle("", forState: .Normal)
    }
    
    func setBlank5678() {
        self.button5.setTitle("", forState: .Normal)
        self.button6.setTitle("", forState: .Normal)
        self.button7.setTitle("", forState: .Normal)
        self.button8.setTitle("", forState: .Normal)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
    
    }
}

