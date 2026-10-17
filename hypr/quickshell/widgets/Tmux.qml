import QtQuick
import Quickshell.Io

import ".."
import "../components"
// i have to fix it , its no working 
Item {
    id: root
    implicitHeight: pill.implicitHeight
    implicitWidth: pill.implicitWidth

    Poller {
        id: tmuxPoller
        command: ["sh", "-c", "/usr/bin/tmux list-sessions 2>/dev/null | wc -l"]
        interval: 10000
    }

    readonly property int sessionCount: {
        if (tmuxPoller.value === null || tmuxPoller.value === undefined) return 0
        const n = parseInt(String(tmuxPoller.value).trim(), 10)
        return isNaN(n) ? 0 : n
    }

    Pill {
        id: pill
        anchors.fill: parent

        icon: ""
        label: root.sessionCount.toString()
        visible: root.sessionCount > 0
        iconColor: Theme.colWhite
    }
}