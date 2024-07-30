import QtQuick 2.5
import QtQuick.Controls 2.15 
import QtQuick.Layouts 1.15
import QtQuick.Window 2.2
import "jsconsole.js" as Util

ApplicationWindow {
    id: root
    title: qsTr("JSConsole")
    width: 640
    height: 480
    
    visible: true

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 9
        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: input
                Layout.fillWidth: true
                focus: true
                onAccepted: {
                    console.log(this);
                    root.jsCall(input.text, this)
                }
            }
            Button {
                text: qsTr("Send")
                onClicked: {
                    console.log(this);
                    root.jsCall(input.text, this)
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Rectangle {
                anchors.fill: parent
                color: '#333'
                border.color: Qt.darker(color)
                opacity: 0.2
                radius: 2
            }

            ScrollView {
                id: scrollView
                anchors.fill: parent
                anchors.margins: 9
                ListView {
                    id: resultView
                    model: ListModel {
                        id: outputModel
                    }
                    delegate: ColumnLayout {
                        width: ListView.view.width
                        Label {
                            Layout.fillWidth: true
                            color: 'green'
                            text: "> " + model.expression
                        }
                        Label {
                            Layout.fillWidth: true
                            color: 'blue'
                            text: "" + model.result
                        }
                        Rectangle {
                            height: 1
                            Layout.fillWidth: true
                            color: '#333'
                            opacity: 0.2
                        }
                    }
                }
            }
        }
    }

    function jsCall(exp, scope) {
        console.log(scope);
        var data = Util.call(exp, scope);
        outputModel.insert(0, data)
    }
}
