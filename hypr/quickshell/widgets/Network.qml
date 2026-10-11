import QtQuick
import Quickshell.Io
import Quickshell

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
    command: "ip -4 -o addr show | awk '$2 ~ /^(tun|tap|wg|ppp)/ { print $4; exit }' | cut -d/ -f1"
    interval: 10000
    }

    property bool isOffline:    namePoller.value === "" || namePoller.value === "(none)"
    property bool isVpnActive:  vpnPoller.value === "1"
    property bool isWifi:       typePoller.value.indexOf("wireless") !== -1
    property bool isEthernet:   typePoller.value.indexOf("ethernet") !== -1

    property string netIcon:
        isOffline ? "󱛅" :
        isVpnActive ? (isWifi ? "VPN" : "VPN") :
        isWifi ? "" :
        isEthernet ? "󰈀" : "󱛅"
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

    // (re)start a Process — stopping it first makes repeat invocations reliable
    function runProc(proc) {
        proc.running = false
        proc.running = true
    }

    // ---- clipboard helper
    Process {
        id: copyIpProc
    }

    Process {
        id: swichtProc
        command: ["sh", "-c", "[ \"$(nmcli -t -f WIFI general)\" = enabled ] && nmcli radio wifi off || nmcli radio wifi on"]
    }

    ClickablePill {
        id: clickablePill
        anchors.fill: parent

        icon:      root.netIcon
        label:     root.netLabel
        iconColor: root.iconColor

        onClicked: (mouse) => {
            // still not working
            if (root.isVpnActive) {
                if (vpnIpPoller.value !== "") {
                    copyIpProc.command = ["wl-copy", vpnIpPoller.value]
                    runProc(copyIpProc)
                    console.log("[NET] copied VPN IP to clipboard: " + vpnIpPoller.value)
                    
                    Quickshell.execDetached(["notify-send", "IP copied to clipboard", vpnIpPoller.value])
                }
            }

            else{
                runProc(swichtProc)
                // no notification?
                Quickshell.execDetached(["notify-send", "Network toggled", "test"])
            }
        }
        onWheel: (dir) => {}
    }
}