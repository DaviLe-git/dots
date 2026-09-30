import QtQuick
import QtQuick.Layouts

import ".."

Rectangle {
    id: root
    property string icon:      ""
    property string label:     ""
    property color  iconColor: Theme.colCyan
    property int    maxLabelWidth: 400

    implicitWidth:  row.implicitWidth + Theme.pillPadding
    implicitHeight: Theme.pillHeight
    radius: height / 2
    color:  Theme.colBg

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.pillSpacing
        Text {
            text:  root.icon
            color: root.iconColor
            font.family:     Theme.fontFamily
            font.pixelSize:  Theme.fontSize
        }
        Text {
            text:  root.label
            color: Theme.colWhite
            font.family:     Theme.fontFamily
            font.pixelSize:  Theme.fontSize
            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth
            visible: root.label !== ""
        }
    }
}