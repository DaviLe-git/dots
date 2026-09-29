import Quickshell
import QtQuick

import "sections"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors {
                top:   true
                left:  true
                right: true
            }

            implicitHeight: Theme.barHeight
            color: "transparent"

            LeftSection {
                anchors.left:            parent.left
                anchors.verticalCenter:  parent.verticalCenter
                anchors.leftMargin:      Theme.edgeMargin
            }

            CenterSection {
                anchors.centerIn: parent
            }

            RightSection {
                anchors.right:           parent.right
                anchors.verticalCenter:   parent.verticalCenter
                anchors.rightMargin:      Theme.edgeMargin
            }
        }
    }
}