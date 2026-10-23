import QtQuick
import ".."

Rectangle {
    id: root

    //PIl
    property var store: null
    signal openEditor()

    property date selectedDate: new Date()
    property date shownMonth: new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    
    // theme
    readonly property color colBg:         Theme.colBg
    readonly property color colBorder:     Theme.colBorder
    readonly property color colText:       Theme.colWhite
    readonly property color colDim:        Theme.colPurple
    readonly property color colHover:      Theme.colHover
    readonly property color colSelectedBg: Theme.colMuted
    readonly property color colSelectedFg: Theme.colRed
    readonly property color colAccent:     Theme.colYellow
    readonly property color colOverdue:    Theme.colRed
    readonly property color colDone:       Theme.colWhite

    
    readonly property int pad: 14
    readonly property int calW: 300
    readonly property int panelW: 290
    readonly property real cellW: calW / 7
    readonly property int cellH: 34

    implicitWidth:  pad * 2 + calW + (store ? panelW + 12 : 0)
    implicitHeight: pad * 2 + calCol.implicitHeight

    color: colBg
    radius: 16
    border.color: colBorder
    border.width: 1

    readonly property var monthNamesFull: ["January","February","March","April","May","June","July","August","September","October","November","December"]
    readonly property var monthNamesShort: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    readonly property var dayNamesShort: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    function daysIn(year, month) { return new Date(year, month + 1, 0).getDate(); }
    function firstWeekday(year, month) { return new Date(year, month, 1).getDay(); } // 0 = domingo
    function isSameDay(a, b) {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate();
    }
    function shiftMonth(delta) {
        shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + delta, 1);
    }
    function resetToSelected() {
        shownMonth = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1);
    }

    function dotColor(d) {
        const key = Qt.formatDate(d, "yyyy-MM-dd");
        const all = store ? store.tasksForDate(d) : [];
        let pend = 0;
        let hasDuePending = false;
        for (let i = 0; i < all.length; i++) {
            if (!all[i].done) {
                pend++;
                if (all[i].due === key) hasDuePending = true;
            }
        }
        if (pend === 0) return colDone;
        const t = new Date(); t.setHours(0, 0, 0, 0);
        return (hasDuePending && d < t) ? colOverdue : colAccent;
    }

    Row {
        id: contentRow
        anchors.fill: parent
        anchors.margins: root.pad
        spacing: 12

        //calendar
        Column {
            id: calCol
            width: root.calW
            spacing: 8

            // ---- header: ‹  October 2026  › ----
            Item {
                width: parent.width
                height: 30

                Item {
                    width: 30; height: parent.height
                    anchors.left: parent.left
                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: arrowL.containsMouse ? root.colText : root.colDim
                        font.pixelSize: 20
                    }
                    MouseArea {
                        id: arrowL
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shiftMonth(-1)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.monthNamesFull[root.shownMonth.getMonth()] + " " + root.shownMonth.getFullYear()
                    color: root.colText
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                Item {
                    width: 30; height: parent.height
                    anchors.right: parent.right
                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: arrowR.containsMouse ? root.colText : root.colDim
                        font.pixelSize: 20
                    }
                    MouseArea {
                        id: arrowR
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shiftMonth(1)
                    }
                }
            }

            // week day
            Grid {
                columns: 7
                width: parent.width
                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    delegate: Item {
                        width: root.cellW
                        height: 18
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: root.colDim
                            font.pixelSize: 11
                        }
                    }
                }
            }

            // grid of days
            Grid {
                columns: 7
                width: parent.width
                Repeater {
                    model: root.firstWeekday(root.shownMonth.getFullYear(), root.shownMonth.getMonth())
                    + root.daysIn(root.shownMonth.getFullYear(), root.shownMonth.getMonth())

                    delegate: Item {
                        id: cell
                        required property int index

                        readonly property int dayNumber: index + 1 - root.firstWeekday(root.shownMonth.getFullYear(), root.shownMonth.getMonth())
                        readonly property bool valid: dayNumber >= 1 && dayNumber <= root.daysIn(root.shownMonth.getFullYear(), root.shownMonth.getMonth())
                        readonly property date cellDate: new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth(), dayNumber)
                        readonly property bool selected: valid && root.isSameDay(cellDate, root.selectedDate)

                        width: root.cellW
                        height: root.cellH

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: 8
                            color: cell.selected ? root.colSelectedBg : root.colHover
                            visible: cell.selected || dayMouse.containsMouse
                        }

                        Text {
                            anchors.centerIn: parent
                            text: cell.valid ? cell.dayNumber : ""
                            color: cell.selected ? root.colSelectedFg : root.colText
                            font.pixelSize: 12
                        }

                        // tasks in the day
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            width: 5; height: 5; radius: 2.5
                            visible: root.store && cell.valid && root.store.tasksForDate(cell.cellDate).some(
                                t => t.created !== null || t.due !== null)
                            //visible: root.store && cell.valid
                                    && root.store.tasksForDate(cell.cellDate).length > 0
                            color: root.dotColor(cell.cellDate)
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: cell.valid
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectedDate = cell.cellDate
                        }
                    }
                }
            }

            // bottom
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: root.dayNamesShort[root.selectedDate.getDay()] + " "
                    + root.monthNamesShort[root.selectedDate.getMonth()] + " "
                    + root.selectedDate.getDate()
                color: root.colAccent
                font.pixelSize: 13
                font.weight: Font.Medium
            }
        }

        // tasks panel
        Item {
            id: panel
            width: root.panelW
            height: parent.height
            visible: root.store !== null

            readonly property string key: Qt.formatDate(root.selectedDate, "yyyy-MM-dd")
            property var dayTasks: root.store ? root.store.tasksForDate(root.selectedDate) : []

            Column {
                id: panelCol
                anchors.fill: parent
                spacing: 8

                // panel header
                Item {
                    width: parent.width
                    height: 20
                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.dayNamesShort[root.selectedDate.getDay()] + " "
                        + root.monthNamesShort[root.selectedDate.getMonth()] + " "
                        + root.selectedDate.getDate()
                        color: root.colAccent
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: panel.dayTasks.length === 0 ? "none"
                        : panel.dayTasks.length + (panel.dayTasks.length === 1 ? " task" : " tasks")
                        color: root.colDim
                        font.pixelSize: 11
                    }
                }

                Rectangle { width: parent.width; height: 1; color: root.colBorder }

                // list with scroll
                Item {
                    width: parent.width
                    height: parent.height - 20 - 1 - 34 - panelCol.spacing * 3

                    Text {
                        visible: panel.dayTasks.length === 0
                        anchors.centerIn: parent
                        text: "No tasks"
                        color: root.colDim
                        font.pixelSize: 12
                    }

                    Flickable {
                        anchors.fill: parent
                        contentHeight: tasksCol.implicitHeight
                        contentWidth: width
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        visible: panel.dayTasks.length > 0

                        Column {
                            id: tasksCol
                            width: parent.width
                            spacing: 2

                            Repeater {
                                model: panel.dayTasks

                                delegate: Item {
                                    id: taskRow
                                    required property var modelData

                                    // tarefa com prazo vencendo/valendo exatamente neste dia
                                    readonly property bool isDue: modelData.due !== null
                                            && modelData.due === panel.key

                                    width: tasksCol.width
                                    height: Math.max(36, taskText.implicitHeight + 14)

                                    // checkbox
                                    Rectangle {
                                        id: check
                                        anchors.left: parent.left
                                        anchors.leftMargin: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 18; height: 18; radius: 5
                                        color: taskRow.modelData.done ? root.colAccent : "transparent"
                                        border.color: taskRow.modelData.done ? root.colAccent : root.colDim
                                        border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            visible: taskRow.modelData.done
                                            color: "#111111"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    // priorities (A/B/C)
                                    Text {
                                        id: prioText
                                        visible: taskRow.modelData.prio !== ""
                                        anchors.left: check.right
                                        anchors.leftMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: taskRow.modelData.prio
                                        color: taskRow.modelData.prio === "A" ? root.colOverdue
                                             : taskRow.modelData.prio === "B" ? root.colAccent : "#d8c85b"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    // text
                                    Text {
                                        id: taskText
                                        anchors.left: prioText.visible ? prioText.right : check.right
                                        anchors.leftMargin: 8
                                        anchors.right: parent.right
                                        anchors.rightMargin: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: taskRow.isDue ? "\uf017 " + taskRow.modelData.display
                                                            : taskRow.modelData.display
                                        color: taskRow.modelData.done ? root.colDone : root.colText
                                        font.pixelSize: 12
                                        font.strikeout: taskRow.modelData.done
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        // dont work yet
                                        onClicked: root.store.toggleDone(taskRow.modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                // Open tuxedo
                Rectangle {
                    width: parent.width
                    height: 34
                    radius: 10
                    color: edMouse.pressed ? root.colHover
                        : edMouse.containsMouse ? "#26262b" : "#19191d"
                    border.color: root.colBorder
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: ""; color: root.colText; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Open tuxedo"; color: root.colText; font.pixelSize: 12; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
                    }

                    MouseArea {
                        id: edMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openEditor()
                    }
                }
            }
        }
    }
}