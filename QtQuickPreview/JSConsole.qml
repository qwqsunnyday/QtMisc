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

    property var predefinedCommands: []

    ListModel {
        id: inputModel
        property int currentIdx: 0
        ListElement {
            // 保证始终在最后面
            modelData: ""
        }
        Component.onCompleted: {
            for (let i = 0; i < predefinedCommands.length ; i++) {
                addCommand(predefinedCommands[i])
                let data = root.jsCall(predefinedCommands[i])
                inspectorModel.insert(0, data)
            }
        }
    }
    ListModel {
        id: outputModel
    }
    ListModel {
        id: inspectorModel
        // ListElement {
        //     expression: "3+4"
        //     result: "7"
        // }
    }
    Component {
        id: cmdEchoDisplayComponent
        Item {
            anchors.fill: parent
            Timer {
                id: timer
                interval: refreshInterval.value
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    if (targetModel == "inspectorModel") {
                        for (let i = 0; i < inspectorModel.count ; i++) {
                            let cmd = inspectorModel.get(i).expression
                            inspectorModel.set(i, root.jsCall(cmd))
                        }
                    }
                }
                Component.onCompleted: {
                    timer.start()
                }
            }

            required property string targetModel
            ScrollView {
                id: scrollView
                clip: true
                anchors.fill: parent
                anchors.margins: 9

                contentHeight: parent.height
                contentWidth: parent.width
                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 25
                    anchors.bottomMargin: 25
                    clip: true
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        id: resultView
                        // 奇技淫巧
                        model: eval(targetModel)
                        delegate: ColumnLayout {
                            required property int index
                            required property var model

                            width: ListView.view.width
                            RowLayout {
                                // Layout.fillHeight: true
                                Layout.fillWidth: true
                                Button {
                                    Layout.fillWidth: true
                                    clip: true
                                    contentItem: Text {
                                        text: "> " + model.expression
                                        font.family: "Consolas"
                                        horizontalAlignment : Text.AlignLeft
                                    }
                                    onClicked: {
                                        Utils.copyToClipBoard(model.expression)
                                    }
                                }
                                Button {
                                    visible: targetModel == "outputModel"
                                    Layout.preferredWidth: contentTxt.contentWidth+20
                                    contentItem: Text {
                                        id: contentTxt
                                        text: "Watch"
                                        horizontalAlignment : Text.AlignLeft
                                    }
                                    onClicked: {
                                        let data = root.jsCall(model.expression)
                                        inspectorModel.insert(0, data)
                                    }
                                }
                                Button {
                                    Layout.preferredWidth: contentTxt1.contentWidth+20
                                    contentItem: Text {
                                        id: contentTxt1
                                        text: "Delete"
                                        horizontalAlignment : Text.AlignLeft
                                    }
                                    onClicked: {
                                        resultView.model.remove(index)
                                    }
                                }
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: contentHeight + 10
                                Flickable {
                                    clip: true
                                    contentWidth: parent.width
                                    contentHeight: btn.implicitHeight
                                    Rectangle {
                                        anchors.fill: parent
                                        Button {
                                            anchors.fill: parent
                                            id: btn
                                            leftPadding: 4
                                            topPadding: 4
                                            rightPadding: 4
                                            bottomPadding: 4
                                            contentItem: Text {
                                                id: resultText
                                                text: "" + model.result
                                                font.family: "Consolas"
                                                horizontalAlignment : Text.AlignLeft
                                            }
                                            onClicked: {
                                                Utils.copyToClipBoard(model.result)
                                            }
                                        }
                                    }
                                }
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
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 1
        Rectangle {
            Layout.fillWidth: true
            // Layout.fillHeight: true
            Layout.preferredHeight: controlZone.implicitHeight + controlZone.anchors.margins*2
            border.color: "#d6d6d6"
            border.width: 2
            RowLayout {
                id: controlZone
                anchors.fill: parent
                anchors.margins: 3
                TextField {
                    id: input
                    Layout.fillWidth: true
                    Layout.minimumWidth: 50
                    focus: true
                    text: inputModel.get(inputModel.currentIdx).modelData
                    onAccepted: {
                        addCommand(input.text)
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
                        addCommand(input.text)
                    }
                }
                DelayButton {
                    text: qsTr("Clear")
                    onClicked: {
                        outputModel.clear()
                        input.text = ""
                    }
                    onActivated: {
                        outputModel.clear()
                        inputModel.clear()
                        inspectorModel.clear()
                        input.text = ""
                        progress = 0
                    }
                }

                Switch {
                    id: historySwitch
                    visible: false
                    text: qsTr("History")
                    checked: false
                }
                Slider {
                    id: refreshInterval
                    from: 100
                    to: 2000
                    value: 200
                    Layout.preferredWidth: 100
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.margins: 9
            ColumnLayout {
                id: consoleZone
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width/2
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

                    Repeater {
                        anchors.fill: parent
                        // 作用是代替Loader
                        model: ListModel {
                            ListElement {
                                targetModel: "outputModel"
                            }
                        }
                        delegate: cmdEchoDisplayComponent
                    }
                }
            }

            ColumnLayout {
                id: inspectorZone
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width/2

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Rectangle {
                        anchors.fill: parent
                        color: '#333'
                        border.color: Qt.darker(color)
                        opacity: 0.2
                        radius: 0
                    }
                    Repeater {
                        model: ListModel {
                            ListElement {
                                targetModel: "inspectorModel"
                            }
                        }
                        delegate: cmdEchoDisplayComponent
                        Component.onCompleted: {
                            console.log(Utils.modelToJSON(inspectorModel))
                        }
                    }
                }
            }
        }
    }

    Component.onDestruction: {
        outputModel.clear()
    }

    function addCommand(cmd) {
        let data = root.jsCall(cmd)
        outputModel.insert(0, data)
        inputModel.insert(inputModel.count-1, {modelData: cmd})
        inputModel.currentIdx = inputModel.count-1
        input.text = ""
    }

    function jsCall(exp) {
        try {
            var result = String(eval(exp));
        } catch (e) {
            result  = e.toString();
        }
        // console.log(JSON.stringify({expression: exp,result: result}))
        return {expression: exp,result: result}
    }
}
