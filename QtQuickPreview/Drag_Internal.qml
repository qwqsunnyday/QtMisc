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
    width: 200
    height: 200

    RowLayout {
        anchors.fill: parent
        Rectangle {
            width: 0.5*parent.width
            height: parent.height
            Item {
                id: canvas
                anchors.fill: parent
                objectName: "canvas"
                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "gray"
                    DropArea {
                        anchors.fill: parent
                        keys: ['text/plain']
                        onDropped: {
                            console.log("dropped")
                            console.log(Utils._QObjectToJson(drag.source.Drag.mimeData))
                        }
                    }
                }


            }
        }
        Rectangle {
            id: dragItem
            // 不锚定住, 就会乱跑
            // anchors.centerIn: Drag.active ? undefined : parent
            // anchors.centerIn: canvas
            // anchors.horizontalCenter: canvas.horizontalCenter
            // anchors.verticalCenter: canvas.verticalCenter
            width: textComponent.implicitWidth + 20
            height: textComponent.implicitHeight + 10
            color: "green"

            Drag.dragType: Drag.Internal
            Drag.supportedActions: Qt.CopyAction
            Drag.mimeData: {
                "text/plain": "Copied text"
            }
            Drag.keys: ["text/plain"]
            states: State {
                when: dragArea.drag.active
                AnchorChanges {
                    target: canvas
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
