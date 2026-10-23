import QtQuick
import ".."

Rectangle {
    id: root

    property date selectedDate: new Date()
    property date shownMonth: new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)

    readonly property int firstWeekdayOfShown: firstWeekday(shownMonth.getFullYear(), shownMonth.getMonth())
    readonly property int daysInShown: daysIn(shownMonth.getFullYear(), shownMonth.getMonth())

    readonly property color colBg:         Theme.colBg
    readonly property color colBorder:     Theme.colBorder
    readonly property color colText:       Theme.colWhite
    readonly property color colDim:        Theme.colPurple
    readonly property color colHover:      "#1c1c20"
    readonly property color colSelectedBg: '#4fc1c1c9'
    readonly property color colSelectedFg: Theme.colRed
    readonly property color colAccent:     Theme.colYellow

    implicitWidth:  300
    implicitHeight: content.implicitHeight + pad * 2
    readonly property int pad: 14
    readonly property real cellW: (implicitWidth - pad * 2) / 7
    readonly property int cellH: 34

    readonly property var monthNamesFull: ["January","February","March","April","May","June","July","August","September","October","November","December"]
    readonly property var monthNamesShort: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    readonly property var dayNamesShort: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    color: colBg
    radius: 16
    border.color: colBorder
    border.width: 1

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

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: root.pad
        spacing: 8

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

        Grid {
            columns: 7
            width: parent.width
            Repeater {
                model: root.firstWeekdayOfShown + root.daysInShown

                delegate: Item {
                    id: cell
                    required property int index

                    readonly property int dayNumber: index + 1 - root.firstWeekdayOfShown
                    readonly property bool valid: dayNumber >= 1 && dayNumber <= root.daysInShown
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
}