//
//  Created by Peter Combee on 13/10/2022.
//

import XCTest
import UIKit

private var AssociatedHandle: UInt8 = 0

extension UIControl.Event: Hashable {}

extension UIControl {
    
    @discardableResult
    func addAction(forEvent event: Event, action: @escaping () -> Void) {
        setListener(event: event, action: action)
    }
    
    private func setListener(event: Event, action: @escaping () -> Void) {
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
    private var listeners: [UIControl.Event: Listener] = [:]

    func setListenerFor(control: UIControl, event: UIControl.Event, action: @escaping () -> Void) {
        listeners[event] = Listener(control: control, for: event, action: action)
    }
}

private final class Listener: NSObject {
    private let action: () -> Void
    
    init(control: UIControl, for event: UIControl.Event, action: @escaping () -> Void) {
        self.action = action
        super.init()
        control.addTarget(self, action: #selector(execute), for: event)
    }
        
    @objc func execute() {
        action()
    }
}

final class UIControl_eventActionsTests: XCTestCase {
    
    func test_addAction_executesActionOnButtonTap() {
        
        let button = UIButton()
        
        var callCount = 0
        button.addAction(forEvent: .touchUpInside) {
            callCount += 1
        }
        
        XCTAssertEqual(callCount, 0, "Expect action not to be executed before button tap")
        
        button.simulate(event: .touchUpInside)
        
        XCTAssertEqual(callCount, 1, "Expect action to be executed after button tap")
        
        button.simulate(event: .touchUpOutside)
        
        XCTAssertEqual(callCount, 1, "Expect action not to be executed other control events")
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
