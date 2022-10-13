# Closure based UIControl.Event handling

Add closure based callbacks for all available UIControl.Events as an alternative to the default target-action pattern

Note: This might no longer be usefull since Apple introduced their own closure based API's in iOS 14

## Usage

    // Adding actions

    let button = UIButton()
    button.addAction(forEvent: .touchUpInside) {
        // do something
    }
    
    let segmentedControl = UISegmentedControl()
    segmentedControl.addAction(forEvent: .valueChanged) {
        // do something
    }

    // Removing actions
    
    let toggle = UISwitch()
    let action = toggle.addAction(forEvent: .valueChanged) {
        // do something
    }
        
    action.remove()
