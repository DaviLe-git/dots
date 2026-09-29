import QtQuick

import ".."              // ← NOVO
import "../components"   // ← NOVO

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Poller {
        id: cpuPoller
        command: "LC_ALL=C top -bn1 | awk '/%Cpu/ {print 100 - $8}'"
        interval: 3000
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon:      ""
        label:     cpuPoller.value + "%"
        iconColor: Theme.colPurple
    }
}