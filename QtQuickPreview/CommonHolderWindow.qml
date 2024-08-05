import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Controls.Universal

Window {
    width: 800
    height: 500
    visible: true
    id: rootWindow

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        Rectangle {
            border.color: "gray"
            border.width: 2
            Layout.minimumHeight: controls.implicitHeight + 10
            Layout.minimumWidth: parent.width
            RowLayout {
                id: controls
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10

                WindowFrameRate {
                    targetWindow: Window.window
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignHCenter
                }
                Button {
                    text: "Reload"
                    font.pixelSize: 16
                    onClicked: {
                        console.log(reloadUrl.text)
                        loadSource()
                    }
                }
                Switch {
                    id: autoReloadSwitch
                    text: "Auto Reload"
                    onCheckedChanged: {
                        if (checked) {
                            timer.start()
                        }
                    }
                }
                Slider {
                    id: autoReloadIntervalSlider
                    from: 100
                    to: 2000
                    value: 1000
                }
                TextField {
                    id: reloadUrl
                    visible: false
                    property string sourceUrl: reloadUrlSelect.currentText
                    placeholderText: sourceUrl
                    text: sourceUrl
                }
                ComboBox {
                    id: reloadUrlSelect
                    model: [
                        "Drag_Automatic.qml",
                        "Drag_Internal.qml",
                        "main.qml",
                        "Temp.qml",
                        "DynamicLoadComponent.qml",
                        "CommonHolderWindow.qml"
                    ]
                    Layout.fillWidth: true
                }
            }
        }

        Loader {
            id: loader
            source: reloadUrl.text
            onSourceChanged: {
                console.log(source)
            }
            // 如果都是这样的话, 会平均分配
            Layout.fillHeight: true
            Layout.fillWidth: true
            GridLayer {
                z: 100
                anchors.fill: parent
            }
        }

        Timer {
            id: timer
            interval: autoReloadIntervalSlider.value
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                if (autoReloadSwitch.checked){
                    loadSource()
                }
            }
        }
        Component.onCompleted: {
            // timer.start()
        }
    }
    function loadSource() {
        loader.setSource(reloadUrl.text + "#" + new Date().getTime())
    }
}
