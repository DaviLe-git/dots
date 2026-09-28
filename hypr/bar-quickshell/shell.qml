import Quickshell
import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Mpris

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            
            property color colBg: "#c4040d0d"
            property color colFg: "#a9b1d6"
            property color colMuted: "#444b6a"
            property color colWhite: "#ffefe7"
            property color colCyan: "#0db9d7"
            property color colBlue: "#7aa2f7"
            property color colYellow: "#e0af68"
            property color colGreen: "#2c6b4d"
            property color colPurple: '#da86f8'
            property string fontFamily: "Iosevka Nerd Font"
            property int fontSize: 15

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 40
            color: "transparent"

            Poller {
                id: clock
                command: "date +%H:%M"
                interval: 6000
            }

            Poller{
                id: cpu
                command: "LC_ALL=C top -bn1 | awk '/%Cpu/ {print 100 - $8}'"
                interval: 3000
            }

            Poller {
                id: vol
                command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf\"%d\", $2 * 100}'"
                interval: 500
            }

            Poller {
                id: bat
                command: "cat /sys/class/power_supply/BAT0/capacity"
                interval: 30000
            }

            Poller {
                id: bt
                command: "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"
                interval: 5000
            }

            Poller {
                id: net
                command: "nmcli -t -f NAME connection show --active | head -n1"
                interval: 5000
            }

            readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null

            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 14
                spacing: 8

                Pill {
                    icon: "󰽰"
                    maxLabelWidth: 400
                    label: bar.player ? `${bar.player.trackArtist || "Unknown"} - ${bar.player.trackTitle || ""}` : ""
                }
            }

            RowLayout {
                id: centerGroup
                anchors.centerIn: parent
                spacing: 8

                Pill {
                    Layout.alignment: Qt.AlignVCenter
                    icon: ""
                    label: clock.value
                    iconColor: colWhite
                }

                Workspaces { Layout.alignment: Qt.AlignVCenter}
            }

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 14
                spacing: 8

                Pill {
                    icon: ""
                    label: cpu.value + "%"
                    iconColor:  colPurple
                }

                Pill {
                    icon: ""
                    label: vol.value + "%"
                    iconColor: colYellow
                }

                Pill {
                    icon: ""
                    label: bat.value + "%"
                    iconColor: colGreen
                }

                Pill {
                    icon: "󰂯"
                    label: bt.value
                    iconColor: colPurple
                }

                Pill {
                    icon: ""
                    label: net.value
                    iconColor: colWhite
                }
            }
        }
    }
}