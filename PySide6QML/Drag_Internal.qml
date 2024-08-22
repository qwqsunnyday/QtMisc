import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
// import QtGraphicalEffects 1.15

import "Utils.js" as Utils

/*
# 文件概述

Drag.Internal类型Drag

具体见Drag_Automatic.qml



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
                                drag.source.anchors.horizontalCenter = undefined
                                drag.source.anchors.verticalCenter = undefined
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

                    // anchors.centerIn: (Drag.active || dragItem.accepted) ? undefined : parent
                    // 以上一句等价于states中进行设置
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: textComponent.implicitWidth + 20
                    height: textComponent.implicitHeight + 10
                    color: "green"

                    Drag.dragType: Drag.Internal
                    Drag.active: dragArea.drag.active
                    Drag.supportedActions: Qt.CopyAction
                    Drag.mimeData: {
                        "key1": "Copied text"
                    }
                    Drag.keys: ["key1"]
                    property bool accepted: false
                    states: State {
                        when: dragArea.drag.active || dragItem.accepted
                        AnchorChanges {
                            target: dragItem
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                    // Drag.active: dragArea.drag.active
                    Text {
                        id: textComponent
                        anchors.centerIn: parent
                        text: "Drag me"
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        drag.target: parent
                        onPressed: {
                            console.log("started")
                            console.log("dragItem.Drag.active: "+dragItem.Drag.active) // false
                            dragItem.Drag.start()
                            console.log("dragItem.Drag.active: "+dragItem.Drag.active) // true
                        }
                        onReleased: {
                            // dragItem.parent = dragItem.Drag.target
                            // console.log(dragItem.Drag.target.objectName)
                            console.log("released")
                            console.log("dragItem.Drag.active: "+dragItem.Drag.active) //true
                            dragItem.Drag.drop()
                            console.log("dragItem.Drag.active: "+dragItem.Drag.active) //false
                        }
                    }
                }
            }
        }
    }
}
