import QtQuick 2.15
import QtQuick.Controls 2.15
// import QtGraphicalEffects 1.15

import "DebugUtils.js" as DebugUtils

Window {
    visible: true
    width: 640
    height: 480

    Rectangle {
        width: 0.5*parent.width
        height: parent.height
        Item {
            id: canvas
            anchors.fill: parent
            objectName: "canvas"
            Rectangle {
                width: 0.3* parent.width
                height: parent.height
                color: "gray"
                DropArea {
                    anchors.fill: parent
                    keys: ['text/plain']
                    onDropped: {
                        console.log("dropped")
                        console.log(DebugUtils._QObjectToJson(drag.source.Drag.mimeData))
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
                x: 100
                y: 150
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
                Drag.active: dragArea.drag.active
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
                        dragItem.Drag.start()
                    }
                    onReleased: {
                        // dragItem.parent = dragItem.Drag.target
                        // console.log(dragItem.Drag.target.objectName)
                        console.log("released")
                        dragItem.Drag.drop()
                    }
                }
            }
        }
    }
}
