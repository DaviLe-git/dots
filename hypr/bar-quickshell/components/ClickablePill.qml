import QtQuick

import ".."              // ← NOVO

Item {
    id: root
    property string icon:      ""
    property string label:     ""
    property color  iconColor: Theme.colCyan
    property int    maxLabelWidth: 400

    signal clicked(var mouse)
    signal wheel(int direction)

    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Pill {
        id: pill
        anchors.fill: parent
        icon:          root.icon
        label:         root.label
        iconColor:     root.iconColor
        maxLabelWidth: root.maxLabelWidth
        scale: mouseArea.pressed ? 0.93 : (mouseArea.containsMouse ? 1.05 : 1.0)
        Behavior on scale {
            NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: (mouse) => root.clicked(mouse)
        onWheel:   (wheel) => root.wheel(wheel.angleDelta.y > 0 ? 1 : -1)
    }
}