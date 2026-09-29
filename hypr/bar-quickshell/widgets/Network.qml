import QtQuick

import ".."
import "../components"

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Poller {
        id: netPoller
        command: "nmcli -t -f NAME connection show --active | head -n1"
        interval: 5000
    }

    Pill {
        id: pill
        anchors.fill: parent
        icon:      ""
        label:     netPoller.value
        iconColor: Theme.colWhite
    }
}