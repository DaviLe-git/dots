import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitHeight: pill.implicitHeight
    implicitWidth: pill.implicitWidth

    property string rawOutput: ""

    readonly property int sessionCount: {
        const n = parseInt(rawOutput.trim(), 10)
        return isNaN(n) ? 0 : n
    }

    Process {
        id: tmuxProc
        command: ["sh", "-c", "/usr/bin/tmux list-sessions 2>/dev/null | wc -l"]

        stdout: SplitParser {
            onRead: (line) => {
                root.rawOutput = line
            }
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: tmuxProc.running = true
    }

    //triggers immediately
    Component.onCompleted: tmuxProc.running = true

    Pill {
        id: pill
        anchors.fill: parent

        icon: ""
        label: root.sessionCount.toString()
        visible: root.sessionCount > 0
        iconColor: Theme.colWhite
    }
}