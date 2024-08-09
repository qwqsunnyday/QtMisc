import QtQuick 2.5
import QtQuick.Controls 2.15 
import QtQuick.Layouts 1.15
import QtQuick.Window 2.2
import QtQuick.Controls.Universal
import "Utils.js" as Utils

Item {
    id: root
    width: 640
    height: 480
    anchors.fill: parent
    visible: true

    // menuBar: MenuBar {
    //     Menu {
    //         title: qsTr("File")
    //         MenuItem {
    //             text: qsTr("Exit")
    //             onTriggered: Qt.quit();
    //         }
    //     }
    // }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 9
        RowLayout {
            Layout.fillWidth: true
            ListModel {
                id: inputModel
                property int currentIdx: 0
                ListElement {
                    // 保证始终在最后面
                    modelData: ""
                }
            }
            TextField {
                id: input
                Layout.fillWidth: true
                focus: true
                text: inputModel.get(inputModel.currentIdx).modelData
                onAccepted: {
                    acceptHandle()
                }
                Keys.onPressed: {
                    switch (event.key) {
                        case Qt.Key_Up:
                            if (inputModel.currentIdx>=1){
                                inputModel.currentIdx-=1
                            }
                            input.text = inputModel.get(inputModel.currentIdx).modelData
                            break
                        case Qt.Key_Down:
                            if (inputModel.currentIdx<inputModel.count-1){
                                inputModel.currentIdx+=1
                            }
                            input.text = inputModel.get(inputModel.currentIdx).modelData
                            break
                    }
                }
            }
            Button {
                text: qsTr("Send")
                onClicked: {
                    acceptHandle()
                }
            }
            Button {
                text: qsTr("Clear")
                onClicked: {
                    outputModel.clear()
                    input.text = ""
                }
            }
            Switch {
                id: historySwitch
                visible: false
                text: qsTr("History")
                checked: false
            }
        }
        ListView {
            id: inputView
            clip: true
            visible: historySwitch.checked
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: inputModel
            delegate: TextField {
                width: inputView.width
                text: "currentIdx: "+inputModel.currentIdx+"modelData: "+model.modelData
                background: Rectangle {
                    anchors.fill: parent
                    border.width: 0
                }
            }
            Rectangle {
                anchors.fill: parent
                color: '#333'
                border.color: Qt.darker(color)
                opacity: 0.2
                radius: 2
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
                radius: 0
            }

            ScrollView {
                id: scrollView
                clip: true
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
    Component.onDestruction: {
        outputModel.clear()
    }

    function acceptHandle() {
        root.jsCall(input.text, this)
        inputModel.insert(inputModel.count-1, {modelData: input.text})
        inputModel.currentIdx = inputModel.count-1
        input.text = ""
    }

    function jsCall(exp, scope) {
        // console.log(scope);
        // var data = Util.call(exp, scope);
        try {
            var result = String(eval(exp));
        } catch (e) {
            result  = e.toString();
        }

        var data = {expression: exp,result: result}
        outputModel.insert(0, data)
    }
}
