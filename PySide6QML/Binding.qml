import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Controls.Universal

Item {
    width: 400
    height: 500
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: "red"
        Rectangle {
            id: target
            color: "yellow"
            width: parent.width*0.6
            height: parent.height
            // 破坏的绑定关系对anchor的无效
            // anchors.right: parent.right
            // anchors.bottom: parent.bottom
            // anchors.left: parent.left
            // height: 200
        }
    }
    Button {
        anchors.right: parent.right
        width: 50
        Text {
            text: "手动指定"
        }
        onClicked: {
            // 会破坏原有绑定关系
            target.width = 100
        }
    }
}
