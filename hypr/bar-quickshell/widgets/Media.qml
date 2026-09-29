import QtQuick
import Quickshell.Services.Mpris

import ".."              // ← NOVO
import "../components"   // ← NOVO

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    readonly property var player:
        Mpris.players.values.find(p => p.isPlaying)
        ?? Mpris.players.values[0]
        ?? null

    Pill {
        id: pill
        anchors.fill: parent
        icon:      "󰽰"
        maxLabelWidth: 400
        iconColor: Theme.colCyan
        label: root.player
            ? `${root.player.trackArtist || "Unknown"} - ${root.player.trackTitle || ""}`
            : ""
    }
}