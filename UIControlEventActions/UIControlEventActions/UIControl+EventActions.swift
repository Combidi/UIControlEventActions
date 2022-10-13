//
//  Created by Peter Combee on 13/10/2022.
//

import UIKit

private var ConfiguratorKey: UInt8 = 0

public extension UIControl {
    struct EventAction {
        private let _remove: () -> Void
        
        init(remove: @escaping () -> Void) {
            _remove = remove
        }
        
        public func remove() {
            _remove()
        }
    }
    
    @discardableResult
    func addAction(forEvent event: Event, action: @escaping () -> Void) -> EventAction {
        addHandler(forEvent: event, action: action)
    }
    
    private func addHandler(forEvent: Event, action: @escaping () -> Void) -> EventAction {
        configurator.addEventHandler(forControl: self, event: forEvent, action: action)
    }
    
    private var configurator: Configurator {
        getConfigurator() ?? setupConfigurator()
    }

    private func getConfigurator() -> Configurator? {
        objc_getAssociatedObject(self, &ConfiguratorKey) as? Configurator
    }
    
    private func setupConfigurator() -> Configurator {
        let eventHandler = Configurator()
        objc_setAssociatedObject(self, &ConfiguratorKey, eventHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return eventHandler
    }
}

private final class Configurator {
    private var eventHandlers = Set<EventHandler>()

    func addEventHandler(forControl control: UIControl, event: UIControl.Event, action: @escaping () -> Void) -> UIControl.EventAction {
        let eventHandler = EventHandler(control: control, for: event, action: action)
        eventHandlers.insert(eventHandler)
        
        return UIControl.EventAction { [weak self] in
            eventHandler.deregister()
            self?.eventHandlers.remove(eventHandler)
        }
    }
}

private final class EventHandler: NSObject {
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
