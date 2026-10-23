import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"

Item {
    id: root
    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Poller {
        id: clockPoller
        command: "date +%H:%M"
        interval: 6000
    }

    TodoStore { id: todoStore }   // todoPath: "/path/custom/todo.txt" if needed

    Process {
        id: tuxedoProc
        command: ["kitty", "-e", "tuxedo"]
    }

    ClickablePill {
        id: pill
        anchors.fill: parent
        icon:      ""
        label:     clockPoller.value
        iconColor: Theme.colWhite
        onClicked: calPopup.visible = !calPopup.visible
    }

    PopupWindow {
        id: calPopup
        visible: false
        color: "transparent"

        implicitWidth:  cal.implicitWidth
        implicitHeight: cal.implicitHeight

        anchor.item: pill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 8
        // anchor.adjustment: PopupAdjustment.Flip // descomente se cortar na borda

        onVisibleChanged: if (visible) cal.resetToSelected()

        CalendarPopup {
            id: cal
            store: todoStore
            onOpenEditor: {
                console.log("[clock] botão tuxedo clicado");
                tuxedoProc.exec(tuxedoProc.command);   
            }
        }
    }
}