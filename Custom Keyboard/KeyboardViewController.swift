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
    var charPressed = ""
    var tappedBlank = false
    var pan: UIPanGestureRecognizer!
//    var hold: UILongPressGestureRecognizer!
    var views = [
        "letters": ["abcd","efgh","ijkl", "mnop", "qrst", "uvwx", "yz.,", "?!⏎'"],
        "symbols": ["123456", "{}\"@", "7890<>", "#$%^", "&*()", "-_=+`~", "/:;'", "\\[]|"],
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
        pan.cancelsTouchesInView = false
        pan.delaysTouchesBegan = false
        self.view.addGestureRecognizer(pan)
        
        var press = UILongPressGestureRecognizer(target: self, action: "holdHandler:")
        press.minimumPressDuration = 0.3
        self.view.addGestureRecognizer(press)
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
                updateKeys("symbols")
            } else if self.caps {
                updateKeys("caps")
            } else {
                updateKeys("letters")
            }
        } else if self.pressed == "" {
            self.tappedBlank = true
        } else {
            self.charPressed = self.pressed
            self.toggle = true
        }
    }

    @IBAction func buttonPressed(sender: UIButton) {
        let title = sender.titleForState(.Normal)!
        if title == "" {
            if self.holdingHasPressed {
//                resetKeys()
            }
            if self.tappedBlank {
                self.tappedBlank = false
                resetKeys()
            }
            self.holding = false
            self.holdingHasPressed = false
            pan.enabled = true
        } else {
            if count(title) == 1 {
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
//            pan.enabled = false
        }
    }

    func respondToPan(gesture: UIPanGestureRecognizer) {
//        hold = UILongPressGestureRecognizer(target: self, action: "holdHandler:")
//        hold.minimumPressDuration = 0.2
        if gesture.state == UIGestureRecognizerState.Began {
//            resetKeys()
//            self.view.addGestureRecognizer(hold)
        }
        if gesture.state == UIGestureRecognizerState.Ended {
            var velocity = gesture.velocityInView(self.view)
            if velocity.y > 0 && abs(velocity.y) > abs(velocity.x) {
                // swipe down

                if self.symbols {
                    self.symbols = false
                    self.caps = false
                    resetKeys()
                } else if self.caps {
                    self.symbols = true
                    self.caps = false
                    resetKeys()

                } else {
                    self.symbols = false
                    self.caps = true
                    resetKeys()
                
                }
            } else if velocity.y < 0 && abs(velocity.y) > abs(velocity.x) {
                // swipe up
                if self.toggle {
                    var proxy = textDocumentProxy as! UITextDocumentProxy
                    proxy.insertText(self.charPressed.uppercaseString)
                    if self.holdingHasPressed && !self.holding {
                        resetKeys()
                    } else if !holdingHasPressed {
                        resetKeys()
                    }
                } else {
                    if self.symbols {
                        self.caps = true
                        self.symbols = false
                        resetKeys()
                    } else if self.caps {
                        self.caps = false
                        self.symbols = false
                        resetKeys()
                    } else {
                        self.symbols = true
                        self.caps = false
                        resetKeys()
                }
                }
            } else if velocity.x > 0 {
                var proxy = textDocumentProxy as! UITextDocumentProxy
                proxy.insertText(" ")
                resetKeys()
            } else if velocity.x < 0 {
                var proxy = textDocumentProxy as! UITextDocumentProxy
                proxy.deleteBackward()
                resetKeys()
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
    
    @IBAction func touchUpOutside(sender: UIButton) {
//        let title = sender.titleForState(.Normal)!
//
//        if count(title) == 1 {
//            var proxy = textDocumentProxy as! UITextDocumentProxy
//            if title == "⏎" {
//                proxy.insertText("\n")
//            } else {
//                proxy.insertText(title.uppercaseString)
//            }
//            if self.holding {
//                self.holdingHasPressed = true
//            } else {
//                resetKeys()
//            }
//        }
//        if self.holdingHasPressed {
//            pan.enabled = false
//        }
    }
    
    func holdHandler(gesture: UIGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
//            pan.enabled = false
        }
        if gesture.state == UIGestureRecognizerState.Ended {
            if self.holdingHasPressed {
                resetKeys()
            }
        }
    }
    
    func updateKeys(setName: String) {
        for (index, set) in enumerate(self.views[setName]!) {
            if self.pressed == set {
                if count(self.pressed) == 6 {
                    if index < 4 {
                        self.button1.setTitle("", forState: .Normal)
                        self.button2.setTitle(String(set[advance(set.startIndex, 0)]), forState: .Normal)
                        self.button3.setTitle("", forState: .Normal)
                        self.button4.setTitle(String(set[advance(set.startIndex, 3)]), forState: .Normal)
                        self.button5.setTitle(String(set[advance(set.startIndex, 1)]), forState: .Normal)
                        self.button6.setTitle(String(set[advance(set.startIndex, 2)]), forState: .Normal)
                        self.button7.setTitle(String(set[advance(set.startIndex, 4)]), forState: .Normal)
                        self.button8.setTitle(String(set[advance(set.startIndex, 5)]), forState: .Normal)
                    } else {
                        self.button1.setTitle(String(set[advance(set.startIndex, 0)]), forState: .Normal)
                        self.button2.setTitle(String(set[advance(set.startIndex, 1)]), forState: .Normal)
                        self.button3.setTitle(String(set[advance(set.startIndex, 3)]), forState: .Normal)
                        self.button4.setTitle(String(set[advance(set.startIndex, 4)]), forState: .Normal)
                        self.button5.setTitle(String(set[advance(set.startIndex, 2)]), forState: .Normal)
                        self.button6.setTitle("", forState: .Normal)
                        self.button7.setTitle(String(set[advance(set.startIndex, 5)]), forState: .Normal)
                        self.button8.setTitle("", forState: .Normal)
                    }

                } else {
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
                }
                break
            }
        }
    }

    func resetKeys() {
        self.toggle = false
        var set: Array<String>
        if self.symbols {
            set = self.views["symbols"]!
        } else if self.caps {
            set = self.views["caps"]!
        } else {
            set = self.views["letters"]!
        }
        self.button1.setTitle(set[0], forState: .Normal)
        self.button2.setTitle(set[1], forState: .Normal)
        self.button3.setTitle(set[2], forState: .Normal)
        self.button4.setTitle(set[3], forState: .Normal)
        self.button5.setTitle(set[4], forState: .Normal)
        self.button6.setTitle(set[5], forState: .Normal)
        self.button7.setTitle(set[6], forState: .Normal)
        self.button8.setTitle(set[7], forState: .Normal)
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

