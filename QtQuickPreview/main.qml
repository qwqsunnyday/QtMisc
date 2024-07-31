import QtQuick 2.15
import QtQuick.Controls 2.15
// import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.15

// ApplicationWindow Window才可以管理窗口相关, 如宽高
Window {
    id: root_window

    minimumHeight: 500
    minimumWidth: 800

    // 要手动设置visible
    visible: true

    MouseArea {
        id: debug
        // 填充父元素
        visible: false
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: false
        onEntered: {}
        onExited: {}
        onWheel: {}
        // 作用: 将视觉层级在上方的元素接收到的事件继续传递至下方(此层级本身在底层, 因此不用传递)
        // propagateComposedEvents: true
        onClicked: mouse => {
                       // MouseEvent mouse
                       // When handling this signal, changing the accepted property of the mouse parameter has no effect,
                       // unless the propagateComposedEvents property is true.
                       // 传递的事件在accepted时结束, 因此手动设置为false
                       // mouse.accepted = false
                       console.log(probe.x + ", " + probe.y + ": " + probe.imlicitWidth + " * " + probe.implicitHeight + " " + probe.width + " * " + probe.height + " " + probe.currentIndex);
                   }
    }
    Item {
        id: root

        anchors.fill: parent
        anchors.margins: 1

        Row {
            anchors.fill: parent

            Rectangle {
                id: leftZone

                height: parent.height
                width: parent.width - rightZone.width
                color: "gray"
                border.color: Qt.lighter(color)
                border.width: 2

                // 不位于容器内的UI元素默认重叠放置, 互不干扰
                Text {
                    text: "Left"
                    // 容器内anchors无效
                    anchors.centerIn: parent
                }
                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    Rectangle {
                        height: 0.7 * parent.height
                        width: parent.width
                        color: "red"

                        Canvas {
                            id: canvas
                            anchors.fill: parent

                            Rectangle {
                                width: 100
                                height: 100
                                color: "black"
                            }
                        }
                    }
                    Rectangle {
                        height: 0.3 * parent.height
                        width: parent.width
                        color: "yellow"
                    }
                }
            }
            Rectangle {
                id: rightZone

                height: parent.height
                width: 300
                color: "gray"
                border.color: Qt.lighter(color)
                border.width: 2
                Text {
                    text: "Right"
                    anchors.centerIn: parent
                }
                Column {
                    // id: probe
                    anchors.fill: parent
                    anchors.margins: 10
                    Rectangle {
                        height: 0.4 * parent.height
                        width: parent.width
                        color: "red"

                        Column {
                            anchors.fill: parent
                            spacing: 10
                            anchors.margins: 20

                            Rectangle {
                                width: parent.width
                                height: 100
                                color: "yellow"
                                Canvas {
                                    id: output
                                    // anchors.fill: parent
                                    // anchors.margins: 10
                                    height: 0.6 * parent.height
                                    width: parent.width
                                    Rectangle {
                                        width: 100
                                        height: 100
                                        // visible: false
                                        color: "black"
                                    }

                                    Image {
                                        id: light
                                        height: 0.6 * parent.height
                                        // width: 0.6 * parent.width
                                        anchors.right: parent.right
                                        anchors.rightMargin: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        fillMode: Image.PreserveAspectFit
                                        source: "./Light_button/Light_close.png"
                                    }
                                }
                            }
                            Slider {
                                // height: 0.2 * parent.height
                                width: parent.width
                                from: 0
                                to: 100
                            }

                            // 为了使用居中
                            RowLayout {
                                // height: 0.2 * parent.height
                                width: parent.width
                                // anchors.centerIn: parent
                                Layout.margins: 10
                                spacing: 10
                                Switch {
                                    // ? * 28
                                    text: "Option 1"
                                    Layout.alignment: Qt.AlignCenter
                                }

                                Switch {
                                    text: "Option 2"
                                    Layout.alignment: Qt.AlignCenter
                                }
                            }
                        }
                    }
                    Rectangle {
                        height: 0.6 * parent.height
                        width: parent.width
                        color: "yellow"

                        SwipeView {
                            id: view

                            // 双向绑定
                            currentIndex: bar.currentIndex
                            anchors.fill: parent

                            // from Item, default false 限制被显示的项是否只在当前区域内显示
                            clip: true
                            Item {
                                id: tutorial
                                Text {
                                    text: "tutorial"
                                    anchors.centerIn: parent
                                }
                            }
                            Item {
                                id: protein
                                Text {
                                    text: "protein"
                                    anchors.centerIn: parent
                                }
                            }
                            Item {
                                id: questions
                                Text {
                                    text: "questions"
                                    anchors.centerIn: parent
                                }
                            }
                            Item {
                                id: load
                                Text {
                                    text: "load"
                                    anchors.centerIn: parent
                                }
                            }
                        }
                        // 注意: 将TabBar放在SwipeView之上防止接受不到鼠标输入
                        TabBar {
                            id: bar
                            width: parent.width

                            // 双向绑定
                            currentIndex: view.currentIndex

                            TabButton {
                                id: probe
                                text: "Tutorial"
                            }
                            TabButton {
                                text: "Protein"
                            }
                            TabButton {
                                text: "Questions"
                            }
                            TabButton {
                                text: "Load"
                            }
                        }

                        PageIndicator {
                            id: indicator

                            count: view.count
                            currentIndex: view.currentIndex

                            anchors.bottom: view.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
    // onWidthChanged: {
    // console.log(root.width + " x " + root.height);
    // }
    WindowFrameRate {
        id: windowFrameRate
        // window为ApplicationWindow的Attached Property
        // https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html
        targetWindow: Window.window
        anchors.centerIn: parent
        visible: true
    }
    // CustomComponent {
    //     // CustomComponent具有的根属性
    //     required_para: "2333"
    //     // CustomComponent具有的根属性, 是button.para的alias
    //     para: 6666
    //     // 基于scope
    //     property int context_var: 114514
    //     anchors.centerIn: parent
    // }
}


/* Item {
id: root

visible: true
width: 1000
height: 800

Row {

    anchors.fill: parent
    layoutDirection: Qt.RightToLeft

    // Upper Half
    Column {
        height: parent.height / 2
        width: parent.width

        TextField {
            width: parent.width
            placeholderText: "Enter text here"
        }

        Slider {
            width: parent.width
            from: 0
            to: 100
        }

        Row {
            width: parent.width

            Switch {
                text: "Option 1"
            }

            Switch {
                text: "Option 2"
            }

            Switch {
                text: "Option 3"
            }
        }
    }

    Column {
        Canvas {
            // width: 300
            height: 0.7 * parent.height
        }
        Flow {
            Rectangle {
                height: 20
                width: 40
            }
            Rectangle {
                height: 20
                width: 40
            }
            Rectangle {
                height: 20
                width: 40
            }
            Rectangle {
                height: 20
                width: 40
            }
            Rectangle {
                height: 20
                width: 40
            }
            Rectangle {
                height: 20
                width: 40
            }
        }
    }

}
} */

/* Item {
visible: true
width: 1000
height: 800
// title: qsTr("Responsive Layout Example")

// Left Side
Rectangle {
    id: leftSide
    width: parent.width - rightSide.width
    height: parent.height
    color: "lightgray"

    Column {
        anchors.fill: parent

        Rectangle {
            height: parent.height * 0.7
            width: parent.width
            color: "lightblue"
        }

        Rectangle {
            height: Math.max(parent.height * 0.3, 100)
            width: parent.width
            color: "lightgreen"
        }
    }
}

// Right Side
Rectangle {
    id: rightSide
    width: 300 // 固定宽度
    height: parent.height
    color: "lightyellow"
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    Column {
        anchors.fill: parent

        // Upper Half
        Column {
            height: parent.height / 2
            width: parent.width

            TextField {
                width: parent.width
                placeholderText: "Enter text here"
            }

            Slider {
                width: parent.width
                from: 0
                to: 100
            }

            Row {
                width: parent.width

                Switch {
                    text: "Option 1"
                }

                Switch {
                    text: "Option 2"
                }

                Switch {
                    text: "Option 3"
                }
            }
        }

        // Lower Half
        Rectangle {
            height: parent.height / 2
            width: parent.width
            color: "lightcoral"
        }
    }
}
}
*/
