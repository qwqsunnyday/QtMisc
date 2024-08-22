import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 200
    height: 100
    // border.color: Qt.lighter("red")

    // property color fillColor: "orange"
    // property color backgroundColor: "white"
    // property string name: "name"
    // property string type: "启动子" // "蛋白质编码区"
    required property color fillColor
    required property color backgroundColor
    required property string name
    required property string type // ["启动子" "蛋白质编码区"]

    Rectangle {
        // x: 300
        // y: 200
        width: 215
        height: 101
        color: "transparent"
        // border.color: Qt.lighter("gray")

        RoundedRectangle {
            // main rect
            borderRadius: 7
            posX: 0
            posY: 50
            rectWidth: 198
            rectHeight: 50
            fillColor: root.fillColor
            strokeColor: root.fillColor
        }
        RoundedRectangle {
            visible: root.type == "启动子"
            borderRadius: 7
            posX: 50
            posY: 10
            rectWidth: 20
            rectHeight: 50
            fillColor: root.fillColor
            strokeColor: root.fillColor
        }
        RoundedRectangle {
            visible: root.type == "启动子"
            borderRadius: 7
            posX: 50
            posY: 10
            rectWidth: 60
            rectHeight: 20
            fillColor: root.fillColor
            strokeColor: root.fillColor
        }
        Circle {
            // left
            visible: root.type != "启动子"
            centerX: 0
            centerY: 75
            radius: 15
            fillColor: root.backgroundColor
            strokeColor: root.backgroundColor
        }
        Circle {
            // right
            centerX: 198
            centerY: 75
            radius: 15
            fillColor: root.fillColor
            strokeColor: root.fillColor
        }

        Triangle {
            visible: root.type == "启动子"
            centerX: 100
            centerY: 20
            triWidth: 12
            triHeight: 20
            fillColor: root.fillColor
            strokeColor: root.fillColor
        }
        Rectangle {
            x: 0
            y: 50
            width: 200
            height: 50
            color: "transparent"
            // border.color: "red"
            Text {
                anchors.centerIn: parent
                text: root.name
                font.pixelSize: 20
            }
        }
    }
}
