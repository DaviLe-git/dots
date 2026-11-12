import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    readonly property int lowThreshold: 20
    readonly property int criticalThreshold: 10

    property bool lowNotified: false
    property bool criticalNotified: false

    readonly property bool onBattery: String(status.value).trim() === "Discharging"

    Poller {
        id: battery
        command: "cat /sys/class/power_supply/BAT0/capacity"
        interval: 30000
        onValueChanged: root.evaluate()
    }

    Poller {
        id: status
        command: "cat /sys/class/power_supply/BAT0/status"
        interval: 8000
        onValueChanged: root.evaluate()
    }

    Process {
        id: notifier
        command: ["notify-send", "-u", "critical", "Battery is Low", ":("]
    }

    function notify(urgency, icon, title, message) {
        notifier.command = ["notify-send", "-u", urgency, "-i", icon, title, message]
        notifier.running = true
    }

    function evaluate() {
        const capacity = parseInt(battery.value, 10)
        if (isNaN(capacity))
            return

        if (!root.onBattery) {
            root.lowNotified = false
            root.criticalNotified = false
            return
        }

        if (capacity > root.lowThreshold)
            root.lowNotified = false
        if (capacity > root.criticalThreshold)
            root.criticalNotified = false

        if (capacity <= root.criticalThreshold && !root.criticalNotified) {
            root.criticalNotified = true
            root.lowNotified = true
            notify("critical", "battery-empty", "Battery is Critical", "Plug in the charger now!")
        } else if (capacity <= root.lowThreshold && !root.lowNotified) {
            root.lowNotified = true
            notify("critical", "battery-low", "Battery is Low", ":(")
        }
    }

    ClickablePill {
        id: pill
        anchors.fill: parent
        icon: root.onBattery ? "" : "󱐋"
        label: battery.value + "%"
        iconColor: (root.onBattery && parseInt(battery.value, 10) <= root.lowThreshold)
                ? Theme.colRed
                : Theme.colGreen
        // have to add the button , and figure out what is gonna do
    }
}