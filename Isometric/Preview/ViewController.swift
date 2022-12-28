//
//  ViewController.swift
//  Preview
//
//  Created by Nicolas Seriot on 17.10.21.
//

import Cocoa

class ViewController: NSViewController {

    var screensaverView: SaverView? = nil
    
    var timer: Timer? = nil
    
    var isAnimating: Bool = false {
        didSet {
            toggleAnimationTimer()
        }
    }
    
    override func loadView() {
        self.screensaverView = SaverView(frame: CGRect.zero, isPreview: true)
        self.view = self.screensaverView ?? NSView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.screensaverView?.setup()
        
        isAnimating = true
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        isAnimating = false
    }
    
    private func toggleAnimationTimer() {
        if isAnimating {
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 1/2.0, repeats: true) { [weak self] (_) in
                    self?.animate()
                }
            }
        } else {
            if let timer = timer {
                timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    func animate() {
        if isAnimating, let screensaverView = screensaverView {
            screensaverView.animateOneFrame()
        }
    }
    
}

