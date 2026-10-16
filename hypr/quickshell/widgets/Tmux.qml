import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitHeight: pill.implicitHeight
    implicitWidth: pill.implicitWidth

    Poller{
        id: tmuxPoller
        command: ""
        interval: 10000
    }

    Pill{
        id: pill
        anchors.fill: parent

        icon: ""
        label: "0"
        iconColor: Theme.colWhite
    }
}