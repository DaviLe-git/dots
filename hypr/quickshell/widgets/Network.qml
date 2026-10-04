import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitWidth:  clickablePill.implicitWidth
    implicitHeight: clickablePill.implicitHeight

    Poller {
        id: namePoller
        command: "nmcli -t -f NAME connection show --active | head -n1"
        interval: 5000
    }

    Poller {
        id: typePoller
        command: "nmcli -t -f TYPE connection show --active | head -n1"
        interval: 5000
    }

    Poller {
        id: vpnPoller
        command: "nmcli -t -f TYPE connection show --active | grep -qE 'vpn|wireguard' && echo 1 || echo 0"
        interval: 5000
    }

    Poller {
        id: vpnIpPoller
        // have to fix it
        command: "dev=$(nmcli -t -f DEVICE,TYPE connection show --active | grep -iE 'vpn|wireguard' | head -n1 | cut -d: -f1); [ -n \"$dev\" ] && ip -4 addr show \"$dev\" 2>/dev/null | grep -oP '(?<=inet )\\d+\\.\\d+\\.\\d+\\.\\d+' | head -n1 || echo ''"
        interval: 10000
    }

    property bool isOffline:    namePoller.value === "" || namePoller.value === "(none)"
    property bool isVpnActive:  vpnPoller.value === "1"
    property bool isWifi:       typePoller.value.indexOf("wireless") !== -1
    property bool isEthernet:   typePoller.value.indexOf("ethernet") !== -1

        //  must check in interval 
    property string netIcon:
        isOffline ? "󱛅" :
        isVpnActive ? (isWifi ? "VPN" : "VPN") :
        isWifi ? "" :
        isEthernet ? "󰈀" : ""
    property color  iconColor:
        isOffline   ? Theme.colMuted :
        isVpnActive ? Theme.colGreen :
        isWifi      ? Theme.colWhite :
        isEthernet ? Theme.colBlue : Theme.colWhite

    property string netLabel:
        isOffline   ? "Offline" :
        isVpnActive && !isWifi && !isEthernet ? "VPN" :
        namePoller.value !== "" ? namePoller.value :
        "—"

    // ---- clipboard helper
    Process {
        id: copyIpProc
        property string ip: ""
        command: ["sh", "-c", "echo -n '" + ip + "' | wl-copy"]
    }

    // ---- visual + interaction
    ClickablePill {
        id: clickablePill
        anchors.fill: parent

        icon:      root.netIcon
        label:     root.netLabel
        iconColor: root.iconColor

        // Clique: só quando VPN está ativa (copia IP local)
        onClicked: (mouse) => {
            if (root.isVpnActive && vpnIpPoller.value !== "") {
                copyIpProc.ip = vpnIpPoller.value
                copyIpProc.running = true
                console.log("[NET] copied VPN IP to clipboard: " + vpnIpPoller.value)
            }
        }

        onWheel: (dir) => {}
    }
}