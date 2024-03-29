//
//  Created by Peter Combee on 13/10/2022.
//

import XCTest
import UIKit
import UIControlEventActions

final class UIControl_eventActionsTests: XCTestCase {
        
    func test_addAction_executesActionOnButtonTap() {
        
        let button = makeButton()
        
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
    
    func test_canAddActionForMultipleEvents() {
        
        let button = makeButton()

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
    
    func test_canAddMultipleActionsPerEvent() {
        
        let button = makeButton()

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
    
    func test_removeActionForDeallocatedControl_hasNoSideEffects() {
        
        var button: UIButton! = makeButton()

        let action = button.addAction(forEvent: .touchDown) {}
        
        button = nil
        
        action.remove()
    }
    
    // MARK: - Helpers
    
    private func makeButton() -> UIButton {
        let button = UIButton()
        trackForMemoryLeaks(button)
        return button
    }
}

// MARK: - Helpers

private extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been delocated. Potential memory leak", file: file, line: line)
        }
    }
}
