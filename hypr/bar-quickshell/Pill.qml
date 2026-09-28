import QtQuick
import QtQuick.Layouts

Rectangle{
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: colCyan
    property int maxLabelWidth: 400

    implicitWidth: row.implicitWidth + 22
    implicitHeight: 33
    radius: height / 2
    color: colBg

    RowLayout{
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text{
            text: root.icon
            color: root.iconColor
            font.family: fontFamily
            font.pixelSize: fontSize
        }

        Text{
            text: root.label
            color: colWhite
            font.family: fontFamily
            font.pixelSize: fontSize
            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth
            visible: root.label != ""
        }
    }
}
