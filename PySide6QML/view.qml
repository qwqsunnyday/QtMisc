import QtQuick 2.0
import QtQuick.Window 2.2

Rectangle {
    width: 200
    height: 200
    color: "green"

    Rectangle { // our inlined button ui
        id: button
        x: 12; y: 12
        width: 116; height: 26
        color: "lightsteelblue"
        border.color: "slategrey"
        Text {
            anchors.centerIn: parent
            text: "Start"
        }MouseArea {
            anchors.fill: parent
            onClicked: {
                status.text = "Button clicked!"
            }
        }
    } Text { // text changes when button was clicked
        id: status
        x: 12; y: 76
        width: 116; height: 26
        text: "waiting ..."
        horizontalAlignment: Text.AlignHCenter
    }
    Rectangle {
        width: 400
        height: 300

        Rectangle {
            id: draggableRectangle
            width: 100
            height: 100
            color: "blue"
            radius: 10

            Drag.active: dragArea.drag.active
            Drag.hotSpot.x: dragArea.width / 2
            Drag.hotSpot.y: dragArea.height / 2

            MouseArea {
                id: dragArea
                anchors.fill: parent
                drag.target: parent
                onPressed: {
                    dragArea.cursorShape = Qt.ClosedHandCursor
                }
                onReleased: {
                    dragArea.cursorShape = Qt.OpenHandCursor
                }
            }
        }
    }
}
