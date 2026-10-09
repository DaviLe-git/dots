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
        // when is charging (also change icon maybe?) , not charging etc;
    }

    Poller{
        id: status
        command: "cat /sys/class/power_supply/BAT0/status"
        interval: 8000
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

    ClickablePill {
        id: pill
        anchors.fill: parent
        //icon:      ""
        icon: status.value === "Not charging" ? "" : "󱐋"
        label:     battery.value + "%"
        iconColor: Theme.colGreen
        // have to add the button , and figure out what is gonna do
    }
}
