import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitWidth:  clickablePill.implicitWidth
    implicitHeight: clickablePill.implicitHeight

    Poller {
        id: btPoller
        command: "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"
        interval: 5000
    }
    
    Process {
        id: btToggle
        command: ["sh", "-c",
            "if bluetoothctl show | grep -q 'Powered: yes'; then bluetoothctl power off; else rfkill unblock bluetooth; bluetoothctl power on; fi"]
        onExited: btPoller.refresh()
    }

    ClickablePill{
        id: clickablePill
        anchors.fill: parent
        icon: "󰂯"
        label: btPoller.value
        iconColor: Theme.colPurple

        onClicked: btToggle.running = true
    }
}