import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitWidth:  clickablePill.implicitWidth
    implicitHeight: clickablePill.implicitHeight

    Poller {
        id: cpuPoller
        command: "LC_ALL=C top -bn1 | awk '/%Cpu/ {print 100 - $8}'"
        interval: 3000
    }

    Process{
        id: bt
        command: ["kitty","-e","htop"]
    }

    ClickablePill{
        id: clickablePill
        anchors.fill: parent
        
        icon:      ""
        label:     cpuPoller.value + "%"
        iconColor: Theme.colPurple
        onClicked: bt.running = true
    }
}