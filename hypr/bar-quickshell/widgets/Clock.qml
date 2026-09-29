import QtQuick

import ".."              // ← NOVO
import "../components"   // ← NOVO

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Poller {
        id: clockPoller
        command: "date +%H:%M"
        interval: 6000
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon:      ""
        label:     clockPoller.value
        iconColor: Theme.colWhite
    }
}