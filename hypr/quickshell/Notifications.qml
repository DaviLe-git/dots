// Credits: https://youtu.be/leCzeCeNxas

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

// To work properly: Kill your notification daemon

Scope{
    id: root
    //property int screenIndex: 0

    property int screenIndex: parseInt(Quickshell.env("QS_SCREEN") || "0")

    NotificationServer{
        id: notificationServer
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            console.log("got:", n.summary, "---", n.body)
            n.tracked = true}
    }
    // still in the wrong monitor :)
    PanelWindow{
        screen: Quickshell.screens[Math.min(root.screenIndex, Quickshell.screens.length - 1)]
        anchors {top:true; right: true}
        margins {top: 50; right: 18}

        implicitHeight: Math.max(1, column.implicitHeight)
        implicitWidth: 300
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore
        focusable: false

        ColumnLayout{
            id: column
            width: parent.width
            spacing: 10

            Repeater{
                model: notificationServer.trackedNotifications
                delegate: Rectangle{
                    id: card
                    required property var modelData
                    
                    Timer{
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: 5000
                        onTriggered: card.modelData.dismiss()
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: layout.implicitHeight + 20
                    radius: 6
                    color: Theme.colBg
                    border.width: 2
                    border.color: modelData.urgency == NotificationUrgency.Critical ? Theme.colRed : Theme.colPurple
                
                    RowLayout{
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image{
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            //source: card.modelData.image || card.modelData.appIcon || "" // old version
                            source: card.modelData.image
                                    ? "file://" + card.modelData.image
                                    : (card.modelData.appIcon || "") //new
                        }

                        ColumnLayout{
                            Layout.fillWidth: true
                            spacing: 2

                            Text{
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Theme.colBlue
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 1
                                font.bold: true
                                elide: Text.ElideRight
                            
                            }

                            Text{
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Theme.colWhite
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                wrapMode: Text.WordWrap
                            }
                        }
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: card.modelData.dismiss()
                }

                }
            }
        }
    }
}

