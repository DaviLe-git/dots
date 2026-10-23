import QtQuick
import Quickshell

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

    ClickablePill {
        id: pill
        anchors.fill: parent
        icon:      ""
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

        // abre abaixo do pill, centralizado nele
        anchor.item: pill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 8
        // anchor.adjustment: PopupAdjustment.Flip // descomente se sair da tela

        // ao abrir, mostra o mês do dia selecionado
        onVisibleChanged: if (visible) cal.resetToSelected()

        CalendarPopup { id: cal }
    }
}