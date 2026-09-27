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
                ? '#c4b1fd'
                : (ws ? "#7aa2f7" : "#444b6a")

            font {
                pixelSize: 14
                bold: true
            }
 
        }
    }
}