import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Poller {
        id: battery
        command: "cat /sys/class/power_supply/BAT0/capacity"
        interval: 30000
        // Must add a notification when battery is low ( with notify-send -u critical ), when is charging (also change icon maybe?) , not charging etc;
    }

    Process {
        id: batteryNotification
        command: [
            "notify-send",
            "-u",
            "critical",
            "Battery is Low",
            ":("
        ]
    }

    Connections {
        target: battery

        function onValueChanged() {
            if (Number(battery.value) <= 20) {
                batteryNotification.running = true
            }
        }
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon:      ""
        label:     battery.value + "%"
        iconColor: Theme.colGreen
    }
}
