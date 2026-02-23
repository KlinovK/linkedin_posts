import Foundation
import UIKit
import Combine

// 1. Retain cycle
class Parent {
    var child: ChildObject?
}
class ChildObject {
    var parent: Parent? // strong = cycle
}

// Fix
class Child {
    weak var parent: Parent? // break the cycle
}

// 2. Strong capture
class ViewModelStrongCapture {
    var onUpdate: (() -> Void)?
    func setup() {
        onUpdate = { self.refresh() } // retains self
    }
    
    // Fix with capture list
    func setupFix() {
        onUpdate = { [weak self] in self?.refresh() }
    }
    
    func refresh() {}
}


// 3. Strong delegate
class DataManagerStrongDelegate {
    var delegate: DataDelegate? // retains delegate
}

// Fix
class DataManagerWeakDelegate {
    weak var delegate: DataDelegate? // protocol must be AnyObject
}

protocol DataDelegate: AnyObject { }

// 4. Never removed
class MyVCObserver: UIViewController {
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle), name: .userDidLogin, object: nil)
    }
    
    // Fix
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handle() {}
}

// 5. Timer retains self
class MyVCTimer: UIViewController {
    var timer: Timer?
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tick() // retains self strongly
        }
    }
    
    // Fix
    func startFixed() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    deinit {
        timer?.invalidate()
    }
    
    func tick() {}
}


