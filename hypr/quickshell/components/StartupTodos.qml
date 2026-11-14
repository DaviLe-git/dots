import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    // ---- configuração ----
    // monitor onde o card aparece (veja os nomes com: hyprctl monitors)
    // se o nome não existir, cai para o 1º monitor da lista
    property string screenName: "eDP-1"
    // mostrar o card mesmo sem tarefas no dia
    property bool showWhenEmpty: false
    // esconder sozinho depois de um tempo (false = só sai no "Close")
    property bool autoHide: false
    property int autoHideMs: 30000
    // vira true no "Close"; volta a false só quando o quickshell reinicia
    property bool dismissed: false

    readonly property date today: new Date()
    readonly property string todayKey: Qt.formatDate(today, "yyyy-MM-dd")

    // tarefas do dia (due:hoje — concluídas aparecem riscadas — + pendentes sem due)
    readonly property var todayTasks: TodoStore.tasksForDate(today)

    // atrasadas: due anterior a hoje e não concluídas (comparação de string ISO vale como data)
    readonly property var overdueTasks: {
        const out = [];
        const ts = TodoStore.tasks;
        for (let i = 0; i < ts.length; i++) {
            if (!ts[i].done && ts[i].due !== null && ts[i].due < root.todayKey)
                out.push(ts[i]);
        }
        return out;
    }

    readonly property int pendingCount: {
        let n = root.overdueTasks.length;
        for (let i = 0; i < root.todayTasks.length; i++)
            if (!root.todayTasks[i].done) n++;
        return n;
    }

    readonly property var dayNames: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    readonly property var monthNames: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

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

        // só aparece se houver algo para mostrar (e não foi fechado)
        visible: !root.dismissed
                 && (root.showWhenEmpty || root.todayTasks.length > 0 || root.overdueTasks.length > 0)

        Rectangle {
            id: card
            width: parent.width
            height: Math.min(cardCol.implicitHeight + 28, 460)

            radius: 16
            color: Theme.colBg
            border.color: Theme.colBorder
            border.width: 1

            ColumnLayout {
                id: cardCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                // ---- cabeçalho ----
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

                // ---- lista com rolagem (atrasadas + do dia) ----
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(scrollCol.implicitHeight, 280)

                    contentHeight: scrollCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: scrollCol
                        width: parent.width
                        spacing: 2

                        // atrasadas
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

                            delegate: Text {
                                required property var modelData
                                Layout.fillWidth: true
                                visible: root.overdueTasks.length > 0
                                text: (modelData.prio !== "" ? "(" + modelData.prio + ") " : "")
                                      + modelData.display
                                color: Theme.colRed
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.topMargin: 4
                            visible: root.overdueTasks.length > 0
                            color: Theme.colBorder
                        }

                        // tarefas do dia (mesmo padrão de linha do CalendarPopup)
                        Repeater {
                            model: root.todayTasks

                            delegate: Item {
                                id: taskRow
                                required property var modelData

                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(30, taskText.implicitHeight + 10)

                                Rectangle {
                                    id: check
                                    anchors.left: parent.left
                                    anchors.leftMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 16; height: 16; radius: 5
                                    color: taskRow.modelData.done ? Theme.colYellow : "transparent"
                                    border.color: taskRow.modelData.done ? Theme.colYellow : Theme.colPurple
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        visible: taskRow.modelData.done
                                        color: "#111111"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }

                                Text {
                                    id: prioText
                                    visible: taskRow.modelData.prio !== ""
                                    anchors.left: check.right
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: taskRow.modelData.prio
                                    color: taskRow.modelData.prio === "A" ? Theme.colRed
                                         : taskRow.modelData.prio === "B" ? Theme.colYellow : "#d8c85b"
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
                                    text: taskRow.modelData.display
                                    color: taskRow.modelData.done ? Theme.colPurple : Theme.colWhite
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    font.strikeout: taskRow.modelData.done
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: TodoStore.toggleDone(taskRow.modelData)
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: root.todayTasks.length === 0 && root.overdueTasks.length === 0
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

    // auto-hide opcional
    Timer {
        running: root.autoHide && win.visible
        interval: root.autoHideMs
        onTriggered: root.dismissed = true
    }
}