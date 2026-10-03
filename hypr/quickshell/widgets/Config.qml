import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitHeight: pill.implicitHeight
    implicitWidth: root.hovered ? 70 : pill.implicitWidth
    property bool hovered: false
    
    Behavior on implicitWidth {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
        }

    Row{
        anchors.fill: parent
        spacing: 1

        Pill{
            id: pill
            visible: !root.hovered
            icon: root.hovered ? "" : "󰍜"
            iconColor: Theme.colWhite
        }
        Pill{
            id: lockbutton
            icon: "󰌾"
            visible: root.hovered
            iconColor: Theme.colWhite

            Process{
                id: lockbt
                command: ["hyprlock"]
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    lockbt.running = true
                }
            }
        }
        Pill{
            id: powerbutton
            icon: "󰐥"
            visible: root.hovered
            iconColor: Theme.colWhite
            
            Process{
                id: powerbt
                command: ["systemctl","poweroff"]
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    powerbt.running = true
                }
            }
        }

    }
    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton
        onEntered: root.hovered = true
        onExited: root.hovered = false

        propagateComposedEvents: true
        z: 100

    }
}