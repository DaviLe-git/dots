import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import ".."              // ← NOVO

RowLayout {
    id: workspaces
    spacing: Theme.sectionSpacing
    implicitWidth:  childrenRect.width
    implicitHeight: 30

    Repeater {
        model: 9
        Item {
            id: wsItem
            property var ws: Hyprland.workspaces.values.find(
                w => w.id === index + 1
            )
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            implicitWidth:  wsText.implicitWidth
            implicitHeight: wsText.implicitHeight

            Text {
                id: wsText
                anchors.centerIn: parent
                text:  index + 1
                color: ma.containsMouse
                    ? Theme.colWhite
                    : (isActive
                    ? Theme.colPurple
                    : (ws ? Theme.colBlue : Theme.colMuted))
                font {
                    family:    Theme.fontFamily
                    pixelSize: Theme.fontSize
                    bold:      true
                }
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}