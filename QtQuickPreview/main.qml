import QtQuick 2.15
import QtQuick.Controls 2.15
// import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.15
// https://doc.qt.io/qt-6.2/qtquickcontrols2-styles.html#using-styles-in-qt-quick-controls
// import QtQuick.Controls.Material

// ApplicationWindow Window才可以管理窗口相关, 如宽高
Window {

    // 指定样式设置
    // Material.background: "black"

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
        // hoverEnabled: false
        // onEntered: {}
        // onExited: {}
        // onWheel: {}
        // 作用: 将视觉层级在上方的MouseArea接收到的事件继续传递至下方MouseArea, 注意仅MouseArea!!!
        propagateComposedEvents: true

        onClicked: (mouse) => {
                       // MouseEvent mouse
                       // When handling this signal, changing the accepted property of the mouse parameter has no effect,
                       // unless the propagateComposedEvents property is true.
                       // 传递的事件在accepted时结束, 因此手动设置为false
                       mouse.accepted = false
                       console.log("top level clicked")
                       // console.log(probe.x + ", " + probe.y + ": " + probe.imlicitWidth + " * " + probe.implicitHeight + " " + probe.width + " * " + probe.height + " " + probe.currentIndex);
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

                            Component {
                                id: bioDevice
                                // require modelData
                                Rectangle {
                                    x: posX; y: posY
                                    width: img.implicitWidth; height: img.implicitHeight
                                    // anchors.fill: parent
                                    color: "transparent"
                                    // color: "red"
                                    // Drag.active: dragArea.drag.active
                                    Drag.supportedActions: Qt.CopyAction
                                    Drag.dragType: Drag.Automatic
                                    Drag.mimeData: {"text/plain": modelData}

                                    // Drag.imageSource: img.source
                                    // MouseArea {
                                    //     id: dragArea
                                    //     anchors.fill: parent
                                    //     drag.target: parent
                                    // }
                                    DragHandler {
                                        onActiveChanged: {
                                            if (active) {
                                                console.log("start")
                                                // The grab happens asynchronously and the JavaScript function callback is invoked
                                                // when the grab is completed.
                                                // The callback takes one argument, which is the result of the grab operation;
                                                // an ItemGrabResult object
                                                parent.grabToImage(function(result) {
                                                    parent.Drag.imageSource = result.url
                                                    parent.Drag.active = true
                                                })
                                            } else {
                                                parent.Drag.active = false
                                            }
                                        }
                                    }

                                    Image {
                                        id: img
                                        source: "Genetic_Element/"+modelData
                                        width: 100; height: 40
                                        fillMode: Image.PreserveAspectFit
                                    }
                                }
                            }

                            ListModel {
                                id: bioDevicesCanvasModel
                            }

                            Repeater {
                                anchors.fill: parent
                                model: bioDevicesCanvasModel
                                delegate: bioDevice
                            }

                            Rectangle {
                                width: 100
                                height: 100
                                color: "black"
                                opacity: 0.5
                            }
                        }
                        DropArea {
                            id: dropArea
                            anchors.fill: parent
                            onDropped: {
                                bioDevicesSourceFlow.forceLayout()

                                var modelData = drop.getDataAsString("text/plain")
                                console.log(modelData+" dropped")
                                bioDevicesCanvasModel.append({"modelData": modelData, "posX": drop.x, "posY": drop.y})
                                console.log(_QObjectToJson(bioDevicesCanvasModel))
                            }
                        }
                    }
                    Rectangle {
                        height: 0.3 * parent.height
                        width: parent.width
                        color: "yellow"

                        Column {
                           anchors.fill: parent
                           anchors.margins: 10
                           spacing: 20
                            Flow {
                                id: bioDevicesSourceFlow
                                // anchors.fill: parent
                                // anchors.margins: 10
                                width: parent.width-10
                                height: parent.height-10
                                spacing: 10

                                ListModel {
                                    id: bioDevicesSourceModel
                                    ListElement { modelData: "9XUAS1.png"}
                                    ListElement { modelData: "CMV1.png"}
                                    ListElement { modelData: "GAL-41.png"}
                                    ListElement { modelData: "INS1.png"}
                                    ListElement { modelData: "Luciferase1.png"}
                                    ListElement { modelData: "miRNA1.png"}
                                    ListElement { modelData: "P-GIP1.png"}
                                    ListElement { modelData: "U6-P1.png"}
                                    ListElement { modelData: "U6-P2.png"}

                                    function getModelIndex(value) {
                                        for (var i = 0; i < this.count; i++) {
                                            if (this.get(i).modelData === value) {
                                                return i;
                                            }
                                        }
                                        return -1;
                                    }
                                }

                                Repeater {
                                    model: bioDevicesSourceModel
                                    Rectangle {
                                        width: img.implicitWidth; height: img.implicitHeight
                                        // anchors.fill: parent
                                        color: "transparent"
                                        // color: "red"
                                        // Drag.dragType 设置为Drag.Automatic时要手动指定下面的
                                        Drag.active: dragArea.drag.active
                                        Drag.dragType: Drag.Automatic
                                        Drag.mimeData: {"text/plain": modelData}
                                        // Drag.supportedActions: Qt.CopyAction

                                        // Drag.imageSource: img.source
                                        MouseArea {
                                            id: dragArea
                                            anchors.fill: parent
                                            drag.target: parent
                                        }
                                        // DragHandler {
                                        //     onActiveChanged: {
                                        //         if (active) {
                                        //             // Repeater语境下可以使用modelData(包括自定义属性)
                                        //             var idx = bioDevicesSourceModel.getModelIndex(modelData)
                                        //             console.log(modelData+ " start, index: "+idx+", "+_QObjectToJson(bioDevicesSourceModel.get(idx)))
                                        //             bioDevicesSourceModel.insert(idx, bioDevicesSourceModel.get(idx))
                                        //             // The grab happens asynchronously and the JavaScript function callback is invoked
                                        //             // when the grab is completed.
                                        //             // The callback takes one argument, which is the result of the grab operation;
                                        //             // an ItemGrabResult object
                                        //             parent.grabToImage(function(result) {
                                        //                 parent.Drag.imageSource = result.url
                                        //                 parent.Drag.active = true
                                        //             })
                                        //         } else {
                                        //             parent.Drag.active = false
                                        //         }
                                        //     }
                                        // }

                                        Image {
                                            id: img
                                            source: "Genetic_Element/"+modelData
                                            width: 100; height: 40
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }
                                }
                            }
                        }
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
                                        id: rectangle
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

                        MouseArea {
                            anchors.fill: parent
                            // 定义一个计时器来聚合滚动事件
                            Timer {
                                id: scrollTimer
                                interval: 100 // 设置合适的时间间隔（毫秒）
                                repeat: false

                                onTriggered: {

                                }
                            }

                            onWheel: {
                                // 响应一次滚动:
                                // 1. 当滚轮事件开始且计时器没有运行
                                // 2. 方向切换了
                                if(wheel.inverted||(!scrollTimer.running)||((Math.abs(wheel.angleDelta.y)>=120)||(Math.abs(wheel.angleDelta.y)>=120))){
                                    scrollTimer.start();
                                    console.log("Handled one scroll event");
                                    if(wheel.angleDelta.x<0||wheel.angleDelta.y<0){
                                        // index遵循C风格
                                        if(bar.currentIndex===bar.count-1){
                                            bar.setCurrentIndex(0)
                                        }else{
                                            bar.incrementCurrentIndex();
                                        }
                                        console.log(bar.currentIndex+" "+bar.count);
                                    }else{
                                        if(bar.currentIndex===0){
                                            bar.setCurrentIndex(bar.count-1)
                                        }else{
                                            bar.decrementCurrentIndex();
                                        }
                                        console.log(bar.currentIndex+" "+bar.count);
                                    }
                                }else{
                                    scrollTimer.restart();
                                }
                               // console.log(wheel.angleDelta);
                            }
                            // onClicked: console.log("mouse clicked"); // 无效
                        }
                        // SwipeView无法直接获取事件响应, 因此将MouseArea放在SwipeView的下面
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

    function _QObjectToJson(qObject) {
        var jsonObject = {};
        var keys = Object.keys(qObject);
        // console.log(keys)
        // console.log(keys[0]+" _ "+qObject[keys[0]]+" _ "+qObject.valueOf(keys[0])["text"]+" _ "+qObject["text"])
        for (var i = 0; i < keys.length ; i++) {
            var value = qObject[keys[i]]
            // 防止循环引用
            if (value !== undefined && keys[i] !== "parent") {
                jsonObject[keys[i]] = value;
            }
        }
        return JSON.stringify(jsonObject, 4);
    }
}


