import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: workspaces

    spacing: 8
    implicitWidth: childrenRect.width
    implicitHeight: 30

    Repeater {
        model: 9

        Text {
            property var ws: Hyprland.workspaces.values.find(
                w => w.id === index + 1
            )

            property bool isActive:
                Hyprland.focusedWorkspace?.id === (index + 1)

            text: index + 1
            color: isActive
                ? colPurple
                : (ws ? colBlue : colMuted)
            font {
                pixelSize: fontSize
                bold: true
            }
        }
    }
    
// Why dont work?
    MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("workspace" + (index + 1))
    }
}