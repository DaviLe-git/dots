import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Poller {
        id: btPoller
        command: "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"
        interval: 5000
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon:      "󰂯"
        label:     btPoller.value
        iconColor: Theme.colPurple
    }

    Process {
        id: btToggle
        command: ["sh", "-c",
            "if bluetoothctl show | grep -q 'Powered: yes'; then bluetoothctl power off; else rfkill unblock bluetooth; bluetoothctl power on; fi"]
        onExited: btPoller.refresh()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    btToggle.running = true
    }
}