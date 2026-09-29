import QtQuick

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
}