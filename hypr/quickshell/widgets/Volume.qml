import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

import ".."
import "../components"

Item {
    id: root

    // ---- layout ------------------------------------------
    implicitWidth:  root.hovered ? 150 : compactPill.implicitWidth
    implicitHeight: Theme.pillHeight

    Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    // ---- state -------------------------------------------
    property bool hovered: false
    property int  currentVol: {
        if (volPoller.value === "M") return 0
        const v = parseInt(volPoller.value)
        return isNaN(v) ? 0 : v
    }
    property bool isMuted: volPoller.value === "M" || currentVol === 0

    //pick icon by volume level
    property string volIcon: isMuted ? "" : ""

    // data source
    Poller {
        id: volPoller
        command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '/MUTED/ {print \"M\"; exit} {printf \"%d\", $2 * 100}'"
        interval: 200
    }

    // COMPACT STATE
    ClickablePill {
        id: compactPill
        anchors.fill: parent
        visible: !root.hovered

        icon:      root.volIcon
        label:     root.isMuted ? "Muted" : (root.currentVol + "%")
        //iconColor: root.isMuted ? Theme.colMuted : Theme.colYellow // Dynamic Color
        iconColor: Theme.colYellow
        onClicked: (mouse) => {}
        onWheel:   (dir)   => (dir > 0 ? upProc : downProc).running = true
    }

    // EXPANDED STATE
    Rectangle {
        id: expandedContainer
        anchors.fill: parent
        visible: root.hovered
        color:  Theme.colBg
        radius: height / 2

        RowLayout {
            anchors.centerIn: parent
            spacing: 7

            Text {
                text:  root.volIcon
                //color: root.isMuted ? Theme.colMuted : Theme.colYellow // Dynamic Color
                color: Theme.colYellow
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            // Slider (drag = set volume)
            Slider {
                id: slider
                Layout.preferredWidth:  70
                Layout.preferredHeight: 10
                from: 0
                to:   100
                value: root.currentVol

                onMoved: {
                    setVolProc.targetVol = Math.round(value)
                    if (setVolProc.running) {
                        setVolProc.pending = true
                    } else {
                        setVolProc.running = true
                    }
                }

                Connections {
                    target: root
                    function onCurrentVolChanged() {
                        if (!slider.pressed) {
                            slider.value = root.currentVol
                        }
                    }
                }

                // Custom Background
                background: Rectangle {
                    x:      slider.leftPadding
                    y:      slider.topPadding + slider.availableHeight / 2 - height / 2
                    width:  slider.availableWidth
                    height: 4
                    radius: 2
                    color:  Theme.colMuted

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color:  Theme.colPurple
                    }
                }

                // ---- custom handle ----
                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth:  12
                    implicitHeight: 12
                    radius: 6
                    color:        Theme.colPurple
                    //border.color: Theme.colWhite
                    border.width: 1
                }
            }

            Text {
                text: (slider.pressed ? Math.round(slider.value) : root.currentVol) + "%"
                color: Theme.colWhite
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }

    MouseArea {
        id: hoverDetector
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        z: 100

        onEntered: root.hovered = true
        onExited:  root.hovered = false
        onWheel:   (wheel) => (wheel.angleDelta.y > 0 ? upProc : downProc).running = true
    }

    // PROCESS RUNNERS
    Process {
        id: upProc
        command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"]
    }
    Process {
        id: downProc
        command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"]
    }
    Process {
        id: setVolProc
        property int  targetVol: 0
        property bool pending:   false
        command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + targetVol + "%"]

        onExited: {
            if (pending) {
                pending = false
                running = true
            }
        }
    }
}