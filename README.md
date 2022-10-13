# Closure based UIControl.Event handling

Add closure based callbacks for all available UIControl.Events as an alternative to the default target-action pattern

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
