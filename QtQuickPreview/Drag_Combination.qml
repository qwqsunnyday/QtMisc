import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Controls.Universal

import "Utils.js" as Utils

/*
# 文件概述


*/

Item {
    visible: true
    width: 400
    height: 400

    Rectangle {
        id: dragInternalDemoArea
        anchors.fill: parent
        Text {
            text: "Drag.Internal Demo Area"
            font.pixelSize: 28
            anchors.horizontalCenter: parent.horizontalCenter
            z: 1
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0
            Rectangle {
                Layout.preferredWidth: parent.width/2
                Layout.fillHeight: true
                color: "gray"
                ColumnLayout  {
                    id: dropCanvas
                    objectName: "canvas"
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.preferredHeight: parent.height/2
                        Layout.fillWidth: true
                        color: "yellow"
                        Text {
                            text: "accept keys: " + drop1.keys
                            anchors.centerIn: parent
                        }
                        DropArea {
                            id: drop1
                            anchors.fill: parent
                            keys: ['key1']
                            onDropped: {
                                console.log("dropped")
                                console.log(Utils._QObjectToJson(drag.source.Drag.mimeData))
                                drag.source.accepted = true
                            }
                        }
                    }
                    Rectangle {
                        Layout.preferredHeight: parent.height/2
                        Layout.fillWidth: true
                        color: "gray"
                        Text {
                            text: "accept keys: " + drop2.keys
                            anchors.centerIn: parent
                        }
                        DropArea {
                            id: drop2
                            anchors.fill: parent
                            keys: ['key2']
                            onDropped: {
                                console.log("dropped")
                                console.log(Utils._QObjectToJson(drag.source.Drag.mimeData))
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: parent.width/2
                Layout.fillHeight: true
                color: "pink"
                Rectangle {
                    id: dragItem
                    // 不锚定住, 就会乱跑

                    anchors.centerIn: (Drag.active || dragItem.accepted) ? undefined : parent
                    // 以上一句等价于states中进行设置
                    width: 80
                    height: 80
                    color: "green"

                    Drag.dragType: modeSwitch.checked ? Drag.Automatic : Drag.Internal
                    Drag.active: dragArea.drag.active
                    Drag.supportedActions: Qt.CopyAction
                    Drag.mimeData: {
                        "key1": "Copied text"
                    }
                    Drag.keys: ["key1"]
                    property bool accepted: false
                    // Drag.active: dragArea.drag.active

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        hoverEnabled: true
                        drag.target: parent
                        onPressed: {
                            console.log("started")
                            console.log("dragItem.Drag.active: "+dragItem.Drag.active) // false
                            if(modeSwitch.checked){
                                // dragItem.Drag.startDrag()
                                dragItem.Drag.hotSpot.x = mouse.x
                                dragItem.Drag.hotSpot.y = mouse.y
                            }else {
                                dragItem.Drag.start()
                            }
                            console.log("dragItem.Drag.active: "+dragItem.Drag.active) // true
                        }
                        onReleased: {
                            console.log("released")
                            console.log("dragItem.Drag.active: "+dragItem.Drag.active) //true
                            if(modeSwitch.checked){
                            }else {
                                dragItem.Drag.drop()
                            }
                            console.log("dragItem.Drag.active: "+dragItem.Drag.active) //false
                        }
                        onEntered: {
                            dragItem.grabToImage(function(result) {
                                dragItem.Drag.imageSource = result.url
                            })
                        }
                    }
                    Switch {
                        id: modeSwitch
                        width: parent.width
                        height: 30
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "Drag me"
                    }
                }
            }
        }
    }
}
