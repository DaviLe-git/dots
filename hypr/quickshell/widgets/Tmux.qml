import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitHeight: pill.implicitHeight
    implicitWidth: pill.implicitWidth

    Pill{
        id: pill
        anchors.fill: parent

        icon: "test"
        label: "test1"
        iconColor: Theme.colWhite
    }
}