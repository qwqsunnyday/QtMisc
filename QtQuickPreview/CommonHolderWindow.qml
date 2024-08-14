import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Controls.Universal

import "Utils.js" as Utils

import FileIO 1.0

/*
# 文件概述

用于实时预览QML文件

## Layout的使用

Layout布局(RowLayout/...)比基于Anchor的锚定布局(Row/Column/...)更加灵活简便, 在使用上接近XAML的StackPanel

一般使用方法:
    1. 使用anchors.fill: parent等指定Layout大小
    2. 子元素使用Layout.alignment设置对齐, 默认为Qt.AlignVCenter | Qt.AlignLeft, 一般不用改变
    3. 子元素使用Layout.fillWidth设置占用剩余空间, 多个为true则平均分配(实用)

对比锚定布局:
    1. 锚定布局需要手动指定宽高和中心对齐
    2. ...

## Control控件与QML中的margin、border和padding

    - margin
        元素边界外面的, 与其他元素边界距离
    - border
        一个边界内部可以着色的边框而已
    - padding
        Control组件边界与内部元素边界的距离
    - inset
        Control组件中边界与background间的距离

## 控件样式

import QtQuick.Controls.Universal

*/
Window {
    width: 800
    height: 600
    visible: true
    id: rootWindow

    flags: alwayOnTopSwitch.checked ? (Qt.Widget | Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowMinMaxButtonsHint | Qt.WindowCloseButtonHint | Qt.WindowStaysOnTopHint) : (Qt.Widget | Qt.Window)

    Window {
        id: consoleWindow
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        Rectangle {
            border.color: "gray"
            border.width: 2
            Layout.minimumHeight: controls.implicitHeight + controls.anchors.margins * 2
            Layout.minimumWidth: parent.width
            RowLayout {
                id: controls
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                // 不会覆盖左右, 因此作用为设置上下margin为10
                anchors.margins: 5
                spacing: 10
                layoutDirection: Qt.RightToLeft

                WindowFrameRate {
                    id: fps
                    // anchors.fill: parent
                    targetWindow: Window.window
                    prefix: ""
                    font.pixelSize: 16
                }
                Button {
                    text: "Console"
                    font.pixelSize: 12
                    onClicked: {
                        var consoleComponent = Qt.createComponent("JSConsole.qml" + "#" + new Date().getTime(), Component.PreferSynchronous, consoleWindow)
                        if (consoleComponent.status == Component.Ready) {
                            var consoleItem = consoleComponent.createObject(consoleWindow);
                            // 可以将consoleItem当作正常组件访问
                            consoleWindow.height = 480
                            consoleWindow.width = 640
                            consoleWindow.show()
                            // console.log(consoleComponent.errorString())
                        }
                    }
                }
                Button {
                    text: "Reload"
                    font.pixelSize: 12
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
                    Layout.fillWidth: true
                    Layout.minimumWidth: 50
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
                    model: JSON.parse(FileIO.read("Assets/qmls.json"))
                    implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                    Layout.fillWidth: true
                    Layout.minimumWidth: 50
                    onActivated: {
                        loadSource()
                    }
                }
                Slider {
                    id: autoReloadIntervalSlider
                    from: 100
                    to: 2000
                    value: 1000
                    // autoReloadIntervalSlider和reloadUrlSelect等共享剩下的所有空间
                    Layout.fillWidth: true
                    Layout.minimumWidth: 50
                }
                Switch {
                    id: gridLayerSwitch
                    text: "Toggle Grid Layer"
                    // 默认值
                    checked: false
                    Layout.fillWidth: true
                    Layout.minimumWidth: 50
                }
                Switch {
                    id: alwayOnTopSwitch
                    text: "Toggle Always On Top"
                    // 默认值
                    checked: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: 50
                }
            }
        }

        Rectangle {
            // border是边界里面的
            border.color: "gray"
            border.width: 2
            // margins是边界外面的, Layout.margins由父级layout-like containers负责
            // Layout.margins: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Loader {
                id: loader
                // source: reloadUrl.text
                onSourceChanged: {
                    console.log(source)
                }
                anchors.fill: parent

                // anchors.margins负责自己的margins
                anchors.margins: 2
                // GridLayer和source使用同一个anchors.margins
                GridLayer {
                    id: gridLayer
                    z: 100
                    anchors.fill: parent
                    visible: gridLayerSwitch.checked
                }
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
            loadSource()
        }
    }
    function loadSource(loadUrl) {
        // "继承"作用域
        loader.setSource(reloadUrl.text + "#" + new Date().getTime())
        // {"flags": Qt.SubWindow}此处可设置Window flags
    }
}
