//
//  Created by Peter Combee on 13/10/2022.
//

import XCTest
import UIKit

private var AssociatedHandle: UInt8 = 0

extension UIControl {
    
    struct EventAction {
        private let _remove: () -> Void
        
        init(remove: @escaping () -> Void) {
            _remove = remove
        }
        func remove() {
            _remove()
        }
    }
    
    @discardableResult
    func addAction(forEvent event: Event, action: @escaping () -> Void) -> EventAction {
        setListener(event: event, action: action)
    }
    
    private func setListener(event: Event, action: @escaping () -> Void) -> EventAction {
        configurator.setListenerFor(control: self, event: event, action: action)
    }
    
    private var configurator: Configurator {
        getConfigurator() ?? setupConfigurator()
    }

    private func getConfigurator() -> Configurator? {
        objc_getAssociatedObject(self, &AssociatedHandle) as? Configurator
    }
    
    private func setupConfigurator() -> Configurator {
        let eventHandler = Configurator()
        objc_setAssociatedObject(self, &AssociatedHandle, eventHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return eventHandler
    }
}

private final class Configurator {
    private var listeners = Set<Listener>()

    func setListenerFor(control: UIControl, event: UIControl.Event, action: @escaping () -> Void) -> UIControl.EventAction {
        let listener = Listener(control: control, for: event, action: action)
        listeners.insert(listener)
        
        return UIControl.EventAction { [weak self] in
            listener.deregister()
            self?.listeners.remove(listener)
        }
    }
}

private final class Listener: NSObject {
    private let action: () -> Void
    private let control: UIControl
    private let event: UIControl.Event
    
    init(control: UIControl, for event: UIControl.Event, action: @escaping () -> Void) {
        self.action = action
        self.control = control
        self.event = event
        super.init()
        control.addTarget(self, action: #selector(execute), for: event)
    }
    
    func deregister() {
        control.removeTarget(self, action: #selector(execute), for: event)
    }
    
    @objc func execute() {
        action()
    }
}

final class UIControl_eventActionsTests: XCTestCase {
    
    func test_addAction_executesActionOnButtonTap() {
        
        let button = UIButton()
        
        var callCount = 0
        let action = button.addAction(forEvent: .touchUpInside) {
            callCount += 1
        }
        
        XCTAssertEqual(callCount, 0, "Expect action not to be executed before button tap")
        
        button.simulate(event: .touchUpInside)
        
        XCTAssertEqual(callCount, 1, "Expect action to be executed after button tap")
        
        button.simulate(event: .touchUpOutside)
        
        XCTAssertEqual(callCount, 1, "Expect action not to be executed other control events")
        
        action.remove()
        button.simulate(event: .touchUpInside)

        XCTAssertEqual(callCount, 1, "Expect action not to be executed once removed")
    }
    
    func test_addAction_forMultipleEvents() {
        
        let button = UIButton()
        var callCount_touchUpInside = 0
        button.addAction(forEvent: .touchUpInside) {
            callCount_touchUpInside += 1
        }
        
        var callCount_touchUpOutside = 0
        button.addAction(forEvent: .touchUpOutside) {
            callCount_touchUpOutside += 1
        }

        button.simulate(event: .touchUpInside)
        button.simulate(event: .touchUpOutside)

        XCTAssertEqual(callCount_touchUpInside, 1)
        XCTAssertEqual(callCount_touchUpOutside, 1)
    }
    
    func test_addMultipleActionsPerEvent() {
        
        let button = UIButton()
        
        var callCount = 0
        button.addAction(forEvent: .touchUpInside) {
            callCount += 1
        }

        button.addAction(forEvent: .touchUpInside) {
            callCount += 1
        }

        button.simulate(event: .touchUpInside)

        XCTAssertEqual(callCount, 2)
    }
}

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
