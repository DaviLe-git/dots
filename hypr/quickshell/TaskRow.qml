import QtQuick
import QtQuick.Layouts

Item {
    id: taskRow

    // a tarefa a mostrar ({ done, prio, created, due, display, raw })
    required property var task
    property color textColor: Theme.colWhite
    property string prefix: ""

    Layout.fillWidth: true
    Layout.preferredHeight: Math.max(30, taskText.implicitHeight + 10)

    Rectangle {
        id: check
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 16; height: 16; radius: 5
        color: taskRow.task.done ? Theme.colYellow : "transparent"
        border.color: taskRow.task.done ? Theme.colYellow : Theme.colPurple
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: "✓"
            visible: taskRow.task.done
            color: "#111111"
            font.pixelSize: 10
            font.bold: true
        }
    }

    Text {
        id: prioText
        visible: taskRow.task.prio !== ""
        anchors.left: check.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: taskRow.task.prio
        color: taskRow.task.prio === "A" ? Theme.colRed
             : taskRow.task.prio === "B" ? Theme.colYellow : "#d8c85b"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        font.bold: true
    }

    Text {
        id: taskText
        anchors.left: prioText.visible ? prioText.right : check.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: taskRow.prefix + taskRow.task.display
        color: taskRow.task.done ? Theme.colPurple : taskRow.textColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.strikeout: taskRow.task.done
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: TodoStore.toggleDone(taskRow.task)
    }
}