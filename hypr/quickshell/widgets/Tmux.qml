import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitHeight: pill.implicitHeight
    implicitWidth: pill.implicitWidth

    Poller {
        id: tmuxPoller
        command: ["sh", "-c", "tmux list-sessions 2>/dev/null | wc -l"]
        interval: 10000
    }

    readonly property string sessionCount: {
        const raw = tmuxPoller.value
        if (raw === null || raw === undefined) return "0"
        const n = parseInt(raw.toString().trim(), 10)
        return isNaN(n) ? "0" : String(n)
    }

    Pill {
        id: pill
        anchors.fill: parent

        icon: ""
        label: root.sessionCount
        visible: root.sessionCount !== "0"
        iconColor: Theme.colWhite
    }
}