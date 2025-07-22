#!/bin/bash

# Safe delay (longer than 1s to ensure the device is ready to rebind)
DELAY=1.5

# Modifier keys to ignore
MODIFIERS=(
  "KEY_LEFTCTRL" "KEY_RIGHTCTRL"
  "KEY_LEFTSHIFT" "KEY_RIGHTSHIFT"
  "KEY_LEFTALT" "KEY_RIGHTALT"
  "KEY_LEFTMETA" "KEY_RIGHTMETA"
)

is_modifier() {
    local key=$1
    for mod in "${MODIFIERS[@]}"; do
        if [[ "$key" == "$mod" ]]; then
            return 0
        fi
    done
    return 1
}

temporarily_disable_touchpad() {
    echo "🔧 Disabling trackpad..." >&2
    INTERFACE_PATH=$(ls -d /sys/bus/usb/drivers/*/*:1.2 2>/dev/null | head -n1)

    if [ -z "$INTERFACE_PATH" ]; then
        echo "WARN: No interface found" >&2
        return
    fi

    INTERFACE_ID=$(basename "$INTERFACE_PATH")
    DRIVER_PATH=$(dirname "$INTERFACE_PATH")

    echo "$INTERFACE_ID" | sudo tee "$DRIVER_PATH/unbind" > /dev/null
    echo "⏱  Sleeping $DELAY seconds..." >&2
    sleep "$DELAY"

    if [ -e "/sys/bus/usb/devices/$INTERFACE_ID" ]; then
        echo "$INTERFACE_ID" | sudo tee "$DRIVER_PATH/bind" > /dev/null
        echo "✅ Rebound $INTERFACE_ID" >&2
    else
        echo "⚠️  Device $INTERFACE_ID not found for rebind" >&2
    fi
}

# Find a keyboard-only device to monitor
KEYBOARD_DEVICE="event4"  
  BEGIN { found=0 }
  /Device:/ { dev="" }
  /Capabilities:.*keyboard/ { found=1 }
  found && /event[0-9]+/ {
    match($0, /event[0-9]+/, m)
    print m[0]
    exit
  }
')

if [ -z "$KEYBOARD_DEVICE" ]; then
    echo "ERROR: Could not find a keyboard device to monitor."
    exit 1
fi

echo "Monitoring keyboard input on: /dev/input/$KEYBOARD_DEVICE"

sudo libinput debug-events --device=/dev/input/$KEYBOARD_DEVICE | \
grep --line-buffered 'KEYBOARD_KEY' | \
while read -r line; do
    keycode=$(echo "$line" | grep -o 'KEY_[A-Z0-9]*')
    echo "Detected key: $keycode" >&2
    if is_modifier "$keycode"; then
        continue
    fi
    temporarily_disable_touchpad
done
