import QtQuick
import QtQuick.Layouts

Item {
    width: 300
    height: 400
    RowLayout {
        anchors.fill: parent
        spacing: 20
        Rectangle {
            color: "red"
            width: 100
            height: 100
            Layout.alignment: Qt.AlignVCenter
        }
        Rectangle {
            color: "yellow"
            width: 100
            height: 100
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
