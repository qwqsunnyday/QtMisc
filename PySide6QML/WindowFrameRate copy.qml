import QtQuick 2.15
import QtQuick.Controls 2.15 

import "Utils.js" as Utils
/*
WindowFrameRate.qml
usage:
    组件名: WindowFrameRate
    顶层属性: window; item的属性
e.g.:
Window {
    // window为indow的Attached Property
    // https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html
    WindowFrameRate {
        id: windowFrameRate
        window: Window.window
        // 如果Window为根元素(id: rootWindow), 则为rootWindow的值, 为了便于集成, 一般使用Window.window之类
    }
}
*/

/*

*/
Text {
    // ApplicationWindow in QtQuick.Controls
    // required property ApplicationWindow targetWindow
    // Window为基类, 具备window的Attached Property
    required property Window targetWindow

    property string prefix: "FPS:"
    property real fps: 0
    property string displayString: prefix + Utils.printf("%3d", fps)

    text: displayString
    font.family: "Consolas"
    // contentWidth文本实际像素长度
    width: contentWidth
    height: contentHeight
    Connections {
        target: targetWindow
        // 使用其他组件的信号
        function onAfterRendering() {
            timer.frameCnt++;
        }
    }

    Timer {
        id: timer
        property real frameCnt: 0

        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            fps = frameCnt;
            frameCnt = 0;
        }
    }
}
