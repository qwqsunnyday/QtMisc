import QtQuick 2.15
import QtQuick.Controls 2.15 
/*
WindowFrameRate.qml
usage:
    组件名: WindowFrameRate
    顶层属性: window; item的属性
e.g.:
ApplicationWindow {
    // window为ApplicationWindow的Attached Property
    // https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html
    WindowFrameRate {
        id: windowFrameRate
        window: ApplicationWindow.window
    }
}
 */
Item {
    // ApplicationWindow in QtQuick.Controls
    // required property ApplicationWindow targetWindow
    // Window为基类, 具备window的Attached Property
    required property Window targetWindow

    property real fps: 0

    Connections {
        target: targetWindow
        function onAfterRendering() {
            timer.frameCnt++;
        }
    }
    
    Text {
        id: fpsDisplay
        text: "FPS:" + fps
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
