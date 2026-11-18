import Quickshell
import QtQuick
import QtQuick.Layouts

import ".."

Scope {
    id: root

    // ---- configuração ----
    property string screenName: "HDMI-A-1"   // nome do monitor: hyprctl monitors
    property bool showWhenEmpty: false    // mostrar card mesmo sem tarefas
    property bool autoHide: false         // esconder sozinho após autoHideMs
    property int autoHideMs: 30000
    property bool dismissed: false        // true após "Close"; volta ao reiniciar

    readonly property date today: new Date()
    readonly property string todayKey: Qt.formatDate(today, "yyyy-MM-dd")

    readonly property var dayNames: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    readonly property var monthNames: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

    // ==========================================================
    // FILTROS — cada binding lê TodoStore.tasks DIRETAMENTE na
    // primeira linha (dependência explícita, re-avalia sempre)
    // ==========================================================

    // atrasadas: due antes de hoje e não concluídas
    readonly property var overdueTasks: {
        const ts = TodoStore.tasks;
        const out = [];
        for (let i = 0; i < ts.length; i++) {
            const t = ts[i];
            if (!t.done && t.due !== null && t.due < root.todayKey) out.push(t);
        }
        return out;
    }

    // agendadas para hoje (concluídas de hoje entram riscadas)
    readonly property var dueTodayTasks: {
        const ts = TodoStore.tasks;
        const out = [];
        for (let i = 0; i < ts.length; i++) {
            if (ts[i].due === root.todayKey) out.push(ts[i]);
        }
        return out;
    }

    // >>> O NOVO: sem data definida -> podem ser feitas qualquer dia
    readonly property var anytimeTasks: {
        const ts = TodoStore.tasks;
        const out = [];
        for (let i = 0; i < ts.length; i++) {
            const t = ts[i];
            if (!t.done && t.due === null) out.push(t);
        }
        return out;
    }

    readonly property int pendingCount: {
        let n = root.overdueTasks.length + root.anytimeTasks.length;
        for (let i = 0; i < root.dueTodayTasks.length; i++)
            if (!root.dueTodayTasks[i].done) n++;
        return n;
    }

    // linha de tarefa reutilizável (inline component)
    component TaskRow: Item {
        id: taskRow

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

    PanelWindow {
        id: win

        screen: Quickshell.screens.find(s => s.name === root.screenName)
                || Quickshell.screens[0]

        anchors { bottom: true; right: true }
        margins { bottom: 60; right: 18 }

        implicitWidth: 340
        implicitHeight: card.height
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore
        focusable: false

        visible: !root.dismissed
                 && (root.showWhenEmpty
                     || root.overdueTasks.length > 0
                     || root.dueTodayTasks.length > 0
                     || root.anytimeTasks.length > 0)

        Rectangle {
            id: card
            width: parent.width
            height: Math.min(cardCol.implicitHeight + 28, 480)

            radius: 16
            color: Theme.colBg
            border.color: Theme.colBorder
            border.width: 1

            ColumnLayout {
                id: cardCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Today — " + root.dayNames[root.today.getDay()] + ", "
                              + root.monthNames[root.today.getMonth()] + " "
                              + root.today.getDate()
                        color: Theme.colWhite
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        font.bold: true
                    }

                    Text {
                        text: root.pendingCount === 0 ? "all done"
                             : root.pendingCount + " pending"
                        color: Theme.colYellow
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.colBorder }

                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(scrollCol.implicitHeight, 300)

                    contentHeight: scrollCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: scrollCol
                        width: parent.width
                        spacing: 2

                        // ---- ATRASADAS ----
                        Text {
                            Layout.fillWidth: true
                            visible: root.overdueTasks.length > 0
                            text: "Overdue (" + root.overdueTasks.length + ")"
                            color: Theme.colRed
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            font.bold: true
                            bottomPadding: 4
                        }

                        Repeater {
                            model: root.overdueTasks
                            delegate: TaskRow {
                                required property var modelData
                                task: modelData
                                textColor: Theme.colRed
                                // prefixo "15/11" = dia que venceu
                                prefix: modelData.due.slice(8) + "/" + modelData.due.slice(5,7) + "  "
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.topMargin: 4
                            visible: root.overdueTasks.length > 0
                            color: Theme.colBorder
                        }

                        // ---- HOJE ----
                        Text {
                            Layout.fillWidth: true
                            visible: root.dueTodayTasks.length > 0
                            text: "Today (" + root.dueTodayTasks.length + ")"
                            color: Theme.colYellow
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            font.bold: true
                            bottomPadding: 4
                        }

                        Repeater {
                            model: root.dueTodayTasks
                            delegate: TaskRow {
                                required property var modelData
                                task: modelData
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.topMargin: 4
                            visible: root.dueTodayTasks.length > 0
                            color: Theme.colBorder
                        }

                        // ---- SEM DATA (a seção nova) ----
                        Text {
                            Layout.fillWidth: true
                            visible: root.anytimeTasks.length > 0
                            text: "Any day (" + root.anytimeTasks.length + ")"
                            color: Theme.colPurple
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            font.bold: true
                            bottomPadding: 4
                        }

                        Repeater {
                            model: root.anytimeTasks
                            delegate: TaskRow {
                                required property var modelData
                                task: modelData
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: root.overdueTasks.length === 0
                                     && root.dueTodayTasks.length === 0
                                     && root.anytimeTasks.length === 0
                            horizontalAlignment: Text.AlignHCenter
                            text: "No tasks for today"
                            color: Theme.colPurple
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            topPadding: 8
                            bottomPadding: 8
                        }
                    }
                }

                // ---- fechar ----
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 10
                    color: closeMouse.pressed ? Theme.colHover
                         : closeMouse.containsMouse ? "#26262b" : "#19191d"
                    border.color: Theme.colBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Close"
                        color: Theme.colWhite
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.dismissed = true
                    }
                }
            }
        }
    }

    Timer {
        running: root.autoHide && win.visible
        interval: root.autoHideMs
        onTriggered: root.dismissed = true
    }
}