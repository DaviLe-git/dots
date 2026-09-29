import QtQuick

import ".."              // ← NOVO
import "../components"   // ← NOVO

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Poller {
        id: batPoller
        command: "cat /sys/class/power_supply/BAT0/capacity"
        interval: 30000
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon:      ""
        label:     batPoller.value + "%"
        iconColor: Theme.colGreen
    }
}