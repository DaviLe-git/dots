import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import ".."

RowLayout {
    id: workspaces
    spacing: Theme.sectionSpacing
    //implicitWidth:  childrenRect.width
    implicitHeight: 30

    Repeater {
        model: 9

        Rectangle {
            id: wsItem
            color: "transparent"
            Layout.preferredWidth:  16
            Layout.preferredHeight: 26
            Layout.alignment:       Qt.AlignVCenter

            property int  wsId:      index + 1
            property var  ws:        Hyprland.workspaces.values.find(w => w.id === wsId)
            property bool isActive: Hyprland.focusedWorkspace?.id === wsId

            Text {
                id: wsText
                anchors.centerIn: parent
                text:  wsId
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
                hoverEnabled:  true
                cursorShape:   Qt.PointingHandCursor

                onClicked: {
                    if (wsItem.ws) wsItem.ws.activate()
                    else Hyprland.dispatch("workspace " + wsId)
                }
            }
        }
    }
}