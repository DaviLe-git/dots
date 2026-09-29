import QtQuick
import Quickshell.Io

import ".."              // ← NOVO
import "../components"   // ← NOVO

Item {
    id: root
    implicitWidth:  clickablePill.implicitWidth
    implicitHeight: clickablePill.implicitHeight

    Poller {
        id: volPoller
        command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '/MUTED/ {print \"M\"; exit} {printf \"%d\", $2 * 100}'"
        interval: 500
    }

    ClickablePill {
        id: clickablePill
        anchors.fill: parent

        icon:  ""
        label: volPoller.value === "M" ? "M" : (volPoller.value + "%")
        iconColor: Theme.colYellow

        onClicked: (mouse) => muteProc.running = true
        onWheel:   (dir)   => (dir > 0 ? upProc : downProc).running = true
    }

    Process {
        id: muteProc
        command: ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
    }
    Process {
        id: upProc
        command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"]
    }
    Process {
        id: downProc
        command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"]
    }
}