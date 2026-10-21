import QtQuick
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root
    implicitWidth:  clickablePill.implicitWidth
    implicitHeight: clickablePill.implicitHeight

    property string _rawName:  ""
    property string _rawTypes: ""
    property string _rawVpnIp: ""


    Process {
        id: namePoller
        command: ["sh", "-c", "nmcli -t -f NAME connection show --active | head -n1"]
        stdout: SplitParser {
            onRead: (line) => { root._rawName = line.trim() }
        }
    }
    Timer { interval: 5000; repeat: true; running: true; onTriggered: namePoller.running = true }

    Process {
        id: typePoller
        command: ["sh", "-c", "nmcli -t -f TYPE connection show --active | paste -sd ',' -"]
        stdout: SplitParser {
            onRead: (line) => { root._rawTypes = line.trim() }
        }
    }
    Timer { interval: 5000; repeat: true; running: true; onTriggered: typePoller.running = true }

    Process {
        id: vpnIpPoller
        command: ["sh", "-c", "ip -4 -o addr show | awk '$2 ~ /^(tun|tap|wg|ppp)/ { print $4; exit }' | cut -d/ -f1"]
        stdout: SplitParser {
            onRead: (line) => { root._rawVpnIp = line.trim() }
        }
    }
    Timer { interval: 10000; repeat: true; running: true; onTriggered: vpnIpPoller.running = true }

    Component.onCompleted: {
        namePoller.running  = true
        typePoller.running  = true
        vpnIpPoller.running = true
    }

    property bool isOffline:    _rawTypes === ""
    property bool isWifi:       _rawTypes.indexOf("wireless") !== -1
    property bool isEthernet:   _rawTypes.indexOf("ethernet") !== -1
    property bool isVpnActive:  _rawTypes.indexOf("vpn") !== -1
                               || _rawTypes.indexOf("wireguard") !== -1

    property string netIcon:
        isOffline    ? "󱛅" :
        isVpnActive  ? (isWifi ? "test" : "test1") :
        isWifi       ? "" :
        isEthernet   ? "󰈀" :
        ""
    property color iconColor:
        isOffline    ? Theme.colMuted  :
        isVpnActive  ? Theme.colGreen :
        isWifi       ? Theme.colWhite  :
        isEthernet   ? Theme.colBlue   :
        Theme.colWhite

    property string netLabel:
        isOffline    ? "Offline" :
        isVpnActive  ? "VPN" :
        _rawName     ? _rawName :
        "—"

    function copyToClipboard(text) {
        if (!text) return
        Quickshell.execDetached(["sh", "-c", "printf '%s' " + JSON.stringify(text) + " | wl-copy"])
        Quickshell.execDetached(["notify-send", "IP copied to clipboard", text])
        console.log("[NET] copied VPN IP: " + text)
    }

    function toggleWifi() {
        Quickshell.execDetached([
            "sh", "-c",
            "[ \"$(nmcli -t -f WIFI general)\" = enabled ] && nmcli radio wifi off || nmcli radio wifi on"
        ])
        Quickshell.execDetached(["notify-send", "Network toggled", ":)"])
    }

    ClickablePill {
        id: clickablePill
        anchors.fill: parent

        icon:      root.netIcon
        label:     root.netLabel
        iconColor: root.iconColor

        onClicked: (mouse) => {
            if (root.isVpnActive) {
                if (root._rawVpnIp !== "") {
                    root.copyToClipboard(root._rawVpnIp)
                } else {
                    Quickshell.execDetached(["notify-send", "No VPN IP found", ""])
                }
            } else {
                root.toggleWifi()
            }
        }
        onWheel: (dir) => {}
    }

} 