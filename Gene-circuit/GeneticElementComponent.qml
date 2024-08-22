import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    width: 200
    height: 100
    color: "transparent"

    // property color fillColor: "orange"
    // property string name: "name"
    // property string type: "启动子" // "蛋白质编码区"
    // property string type: "蛋白质编码区"
    required property color fillColor
    required property string name
    required property string type // ["启动子" | "蛋白质编码区"]
    required property url sourceUrl

    Image {
        id: svgImage
        source: sourceUrl
        width: parent.width
        // height: parent.height
        anchors.bottom: parent.bottom
        fillMode: Image.PreserveAspectFit
    }
    ColorOverlay {
        anchors.fill: svgImage
        source: svgImage
        color: fillColor  // 你想要的颜色
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
            color: "white"
        }
    }
}
