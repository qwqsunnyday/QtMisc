import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "Utils.js" as Utils

Rectangle {
    id: outerSquare
    width: 200
    height: 200
    color: "blue"
    anchors.centerIn: parent

    // 内层透明的正方形
    Rectangle {
        id: innerSquare
        width: 100
        height: 100
        color: "transparent"
        anchors.centerIn: parent
        border.color: "transparent"  // 内层正方形边框透明
    }
}

// Rectangle {
//     x: 300
//     y: 400
//     width: 200
//     height: 100
//     border.color: Qt.lighter("gray")
//     Rectangle {
//         // x: 300
//         // y: 200
//         width: 215
//         height: 101
//         color: "transparent"
//         border.color: Qt.lighter("gray")

//         RoundedRectangle {
//             borderRadius: 7
//             posX: 0
//             posY: 50
//             rectWidth: 198
//             rectHeight: 50
//             fillColor: "orange"
//             strokeColor: "orange"
//         }
//         RoundedRectangle {
//             borderRadius: 7
//             posX: 50
//             posY: 10
//             rectWidth: 20
//             rectHeight: 50
//             fillColor: "orange"
//             strokeColor: "orange"
//         }
//         RoundedRectangle {
//             borderRadius: 7
//             posX: 50
//             posY: 10
//             rectWidth: 60
//             rectHeight: 20
//             fillColor: "orange"
//             strokeColor: "orange"
//         }
//         Circle {
//             centerX: 198
//             centerY: 75
//             radius: 15
//             fillColor: "orange"
//             strokeColor: "orange"
//         }
//         Circle {
//             centerX: 0
//             centerY: 75
//             radius: 15
//             fillColor: "white"
//             strokeColor: "gray"
//         }
//         Triangle {
//             centerX: 100
//             centerY: 20
//             triWidth: 12
//             triHeight: 20
//             fillColor: "orange"
//             strokeColor: "orange"
//         }
//     }
// }

// // ApplicationWindow Window才可以管理窗口相关, 如宽高
// Window {

//     // 指定样式设置
//     // Material.background: "black"

//     id: root_window

//     minimumHeight: 500
//     minimumWidth: 800
//     // 要手动设置visible
//     visible: true

//     MouseArea {
//         id: debug
//         // 填充父元素
//         visible: false
//         anchors.fill: parent
//         cursorShape: Qt.PointingHandCursor
//         // hoverEnabled: false
//         // onEntered: {}
//         // onExited: {}
//         // onWheel: {}
//         // 作用: 将视觉层级在上方的MouseArea接收到的事件继续传递至下方MouseArea, 注意仅MouseArea!!!
//         propagateComposedEvents: true

//         onClicked: (mouse) => {
//                        // MouseEvent mouse
//                        // When handling this signal, changing the accepted property of the mouse parameter has no effect,
//                        // unless the propagateComposedEvents property is true.
//                        // 传递的事件在accepted时结束, 因此手动设置为false
//                        mouse.accepted = false
//                        console.log("top level clicked")
//                        // console.log(probe.x + ", " + probe.y + ": " + probe.imlicitWidth + " * " + probe.implicitHeight + " " + probe.width + " * " + probe.height + " " + probe.currentIndex);
//                    }
//     }
//     Item {
//         id: root

//         anchors.fill: parent
//         anchors.margins: 1

//         Row {
//             anchors.fill: parent

//             Rectangle {
//                 id: leftZone

//                 height: parent.height
//                 width: parent.width - rightZone.width
//                 color: "gray"
//                 border.color: Qt.lighter(color)
//                 border.width: 2

//                 // 不位于容器内的UI元素默认重叠放置, 互不干扰
//                 Text {
//                     text: "Left"
//                     // 容器内anchors无效
//                     anchors.centerIn: parent
//                 }
//                 Column {
//                     anchors.fill: parent
//                     anchors.margins: 10
//                     Rectangle {
//                         height: 0.7 * parent.height
//                         width: parent.width
//                         color: "red"

//                         Canvas {
//                             id: canvas
//                             anchors.fill: parent

//                             Component {
//                                 id: bioDevice
//                                 // require modelData
//                                 Rectangle {
//                                     x: posX; y: posY
//                                     width: img.implicitWidth; height: img.implicitHeight
//                                     // anchors.fill: parent
//                                     color: "transparent"
//                                     // color: "red"
//                                     // Drag.active: dragArea.drag.active
//                                     Drag.supportedActions: Qt.CopyAction
//                                     Drag.dragType: Drag.Automatic
//                                     Drag.mimeData: {"text/plain": modelData}

//                                     // Drag.imageSource: img.source
//                                     // MouseArea {
//                                     //     id: dragArea
//                                     //     anchors.fill: parent
//                                     //     drag.target: parent
//                                     // }
//                                     DragHandler {
//                                         onActiveChanged: {
//                                             if (active) {
//                                                 console.log("start")
//                                                 // The grab happens asynchronously and the JavaScript function callback is invoked
//                                                 // when the grab is completed.
//                                                 // The callback takes one argument, which is the result of the grab operation;
//                                                 // an ItemGrabResult object
//                                                 parent.grabToImage(function(result) {
//                                                     parent.Drag.imageSource = result.url
//                                                     parent.Drag.active = true
//                                                 })
//                                             } else {
//                                                 parent.Drag.active = false
//                                             }
//                                         }
//                                     }

//                                     Image {
//                                         id: img
//                                         source: "Genetic_Element/"+modelData
//                                         width: 100; height: 40
//                                         fillMode: Image.PreserveAspectFit
//                                     }
//                                 }
//                             }

//                             ListModel {
//                                 id: bioDevicesCanvasModel
//                             }

//                             Repeater {
//                                 anchors.fill: parent
//                                 model: bioDevicesCanvasModel
//                                 delegate: bioDevice
//                             }

//                             Rectangle {
//                                 width: 100
//                                 height: 100
//                                 color: "black"
//                                 opacity: 0.5
//                             }
//                         }
//                         DropArea {
//                             id: dropArea
//                             anchors.fill: parent
//                             onDropped: {
//                                 bioDevicesSourceFlow.forceLayout()

//                                 var modelData = drop.getDataAsString("text/plain")
//                                 console.log(modelData+" dropped")
//                                 bioDevicesCanvasModel.append({"modelData": modelData, "posX": drop.x, "posY": drop.y})
//                                 console.log(_QObjectToJson(bioDevicesCanvasModel))
//                             }
//                         }
//                     }
//                     Rectangle {
//                         height: 0.3 * parent.height
//                         width: parent.width
//                         color: "yellow"

//                         Column {
//                            anchors.fill: parent
//                            anchors.margins: 10
//                            spacing: 20
//                             Flow {
//                                 id: bioDevicesSourceFlow
//                                 // anchors.fill: parent
//                                 // anchors.margins: 10
//                                 width: parent.width-10
//                                 height: parent.height-10
//                                 spacing: 10

//                                 ListModel {
//                                     id: bioDevicesSourceModel
//                                     ListElement { modelData: "9XUAS1.png"}
//                                     ListElement { modelData: "CMV1.png"}
//                                     ListElement { modelData: "GAL-41.png"}
//                                     ListElement { modelData: "INS1.png"}
//                                     ListElement { modelData: "Luciferase1.png"}
//                                     ListElement { modelData: "miRNA1.png"}
//                                     ListElement { modelData: "P-GIP1.png"}
//                                     ListElement { modelData: "U6-P1.png"}
//                                     ListElement { modelData: "U6-P2.png"}

//                                     function getModelIndex(value) {
//                                         for (var i = 0; i < this.count; i++) {
//                                             if (this.get(i).modelData === value) {
//                                                 return i;
//                                             }
//                                         }
//                                         return -1;
//                                     }
//                                 }

//                                 Repeater {
//                                     model: bioDevicesSourceModel
//                                     Rectangle {
//                                         width: img.implicitWidth; height: img.implicitHeight
//                                         // anchors.fill: parent
//                                         color: "transparent"
//                                         // color: "red"
//                                         // Drag.dragType 设置为Drag.Automatic时要手动指定下面的
//                                         Drag.active: dragArea.drag.active
//                                         Drag.dragType: Drag.Automatic
//                                         Drag.mimeData: {"text/plain": modelData}
//                                         // Drag.supportedActions: Qt.CopyAction

//                                         // Drag.imageSource: img.source
//                                         MouseArea {
//                                             id: dragArea
//                                             anchors.fill: parent
//                                             drag.target: parent
//                                         }
//                                         // DragHandler {
//                                         //     onActiveChanged: {
//                                         //         if (active) {
//                                         //             // Repeater语境下可以使用modelData(包括自定义属性)
//                                         //             var idx = bioDevicesSourceModel.getModelIndex(modelData)
//                                         //             console.log(modelData+ " start, index: "+idx+", "+_QObjectToJson(bioDevicesSourceModel.get(idx)))
//                                         //             bioDevicesSourceModel.insert(idx, bioDevicesSourceModel.get(idx))
//                                         //             // The grab happens asynchronously and the JavaScript function callback is invoked
//                                         //             // when the grab is completed.
//                                         //             // The callback takes one argument, which is the result of the grab operation;
//                                         //             // an ItemGrabResult object
//                                         //             parent.grabToImage(function(result) {
//                                         //                 parent.Drag.imageSource = result.url
//                                         //                 parent.Drag.active = true
//                                         //             })
//                                         //         } else {
//                                         //             parent.Drag.active = false
//                                         //         }
//                                         //     }
//                                         // }

//                                         Image {
//                                             id: img
//                                             source: "Genetic_Element/"+modelData
//                                             width: 100; height: 40
//                                             fillMode: Image.PreserveAspectFit
//                                         }
//                                     }
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//             Rectangle {
//                 id: rightZone

//                 height: parent.height
//                 width: 300
//                 color: "gray"
//                 border.color: Qt.lighter(color)
//                 border.width: 2
//                 Text {
//                     text: "Right"
//                     anchors.centerIn: parent
//                 }
//                 Column {
//                     // id: probe
//                     anchors.fill: parent
//                     anchors.margins: 10
//                     Rectangle {
//                         height: 0.4 * parent.height
//                         width: parent.width
//                         color: "red"

//                         Column {
//                             anchors.fill: parent
//                             spacing: 10
//                             anchors.margins: 20

//                             Rectangle {
//                                 width: parent.width
//                                 height: 100
//                                 color: "yellow"
//                                 Canvas {
//                                     id: output
//                                     // anchors.fill: parent
//                                     // anchors.margins: 10
//                                     height: 0.6 * parent.height
//                                     width: parent.width
//                                     Rectangle {
//                                         id: rectangle
//                                         width: 100
//                                         height: 100
//                                         // visible: false
//                                         color: "black"
//                                     }

//                                     Image {
//                                         id: light
//                                         height: 0.6 * parent.height
//                                         // width: 0.6 * parent.width
//                                         anchors.right: parent.right
//                                         anchors.rightMargin: 30
//                                         anchors.verticalCenter: parent.verticalCenter
//                                         fillMode: Image.PreserveAspectFit
//                                         source: "./Light_button/Light_close.png"
//                                     }
//                                 }
//                             }
//                             Slider {
//                                 // height: 0.2 * parent.height
//                                 width: parent.width
//                                 from: 0
//                                 to: 100
//                             }

//                             // 为了使用居中
//                             RowLayout {
//                                 // height: 0.2 * parent.height
//                                 width: parent.width
//                                 // anchors.centerIn: parent
//                                 Layout.margins: 10
//                                 spacing: 10
//                                 Switch {
//                                     // ? * 28
//                                     text: "Option 1"
//                                     Layout.alignment: Qt.AlignCenter
//                                 }

//                                 Switch {
//                                     text: "Option 2"
//                                     Layout.alignment: Qt.AlignCenter
//                                 }
//                             }
//                         }
//                     }
//                     Rectangle {
//                         height: 0.6 * parent.height
//                         width: parent.width
//                         color: "yellow"

//                         MouseArea {
//                             anchors.fill: parent
//                             // 定义一个计时器来聚合滚动事件
//                             Timer {
//                                 id: scrollTimer
//                                 interval: 100 // 设置合适的时间间隔（毫秒）
//                                 repeat: false

//                                 onTriggered: {

//                                 }
//                             }

//                             onWheel: {
//                                 // 响应一次滚动:
//                                 // 1. 当滚轮事件开始且计时器没有运行
//                                 // 2. 方向切换了
//                                 if(wheel.inverted||(!scrollTimer.running)||((Math.abs(wheel.angleDelta.y)>=120)||(Math.abs(wheel.angleDelta.y)>=120))){
//                                     scrollTimer.start();
//                                     console.log("Handled one scroll event");
//                                     if(wheel.angleDelta.x<0||wheel.angleDelta.y<0){
//                                         // index遵循C风格
//                                         if(bar.currentIndex===bar.count-1){
//                                             bar.setCurrentIndex(0)
//                                         }else{
//                                             bar.incrementCurrentIndex();
//                                         }
//                                         console.log(bar.currentIndex+" "+bar.count);
//                                     }else{
//                                         if(bar.currentIndex===0){
//                                             bar.setCurrentIndex(bar.count-1)
//                                         }else{
//                                             bar.decrementCurrentIndex();
//                                         }
//                                         console.log(bar.currentIndex+" "+bar.count);
//                                     }
//                                 }else{
//                                     scrollTimer.restart();
//                                 }
//                                // console.log(wheel.angleDelta);
//                             }
//                             // onClicked: console.log("mouse clicked"); // 无效
//                         }
//                         // SwipeView无法直接获取事件响应, 因此将MouseArea放在SwipeView的下面
//                         SwipeView {
//                             id: view

//                             // 双向绑定
//                             currentIndex: bar.currentIndex

//                             anchors.fill: parent

//                             // from Item, default false 限制被显示的项是否只在当前区域内显示
//                             clip: true
//                             Item {
//                                 id: tutorial
//                                 Text {
//                                     text: "tutorial"
//                                     anchors.centerIn: parent
//                                 }
//                             }
//                             Item {
//                                 id: protein
//                                 Text {
//                                     text: "protein"
//                                     anchors.centerIn: parent
//                                 }
//                             }
//                             Item {
//                                 id: questions
//                                 Text {
//                                     text: "questions"
//                                     anchors.centerIn: parent
//                                 }
//                             }
//                             Item {
//                                 id: load
//                                 Text {
//                                     text: "load"
//                                     anchors.centerIn: parent
//                                 }
//                             }
//                         }

//                         // 注意: 将TabBar放在SwipeView之上防止接受不到鼠标输入
//                         TabBar {
//                             id: bar
//                             width: parent.width

//                             // 双向绑定
//                             currentIndex: view.currentIndex

//                             TabButton {
//                                 text: "Tutorial"
//                             }
//                             TabButton {
//                                 text: "Protein"
//                             }
//                             TabButton {
//                                 text: "Questions"
//                             }
//                             TabButton {
//                                 text: "Load"
//                             }
//                         }

//                         PageIndicator {
//                             id: indicator

//                             count: view.count
//                             currentIndex: view.currentIndex

//                             anchors.bottom: view.bottom
//                             anchors.horizontalCenter: parent.horizontalCenter
//                         }
//                     }
//                 }
//             }
//         }
//     }


//     // onWidthChanged: {
//     // console.log(root.width + " x " + root.height);
//     // }
//     WindowFrameRate {
//         id: windowFrameRate
//         // window为ApplicationWindow的Attached Property
//         // https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html
//         targetWindow: Window.window
//         anchors.centerIn: parent
//         visible: true
//     }

//     function _QObjectToJson(qObject) {
//         var jsonObject = {};
//         var keys = Object.keys(qObject);
//         // console.log(keys)
//         // console.log(keys[0]+" _ "+qObject[keys[0]]+" _ "+qObject.valueOf(keys[0])["text"]+" _ "+qObject["text"])
//         for (var i = 0; i < keys.length ; i++) {
//             var value = qObject[keys[i]]
//             // 防止循环引用
//             if (value !== undefined && keys[i] !== "parent") {
//                 jsonObject[keys[i]] = value;
//             }
//         }
//         return JSON.stringify(jsonObject, 4);
//     }
// }



// Window {
//     id: root
//     width: 640
//     height: 480
//     color: "#ffffff"
//     visible: true
//     ListModel {
//         id: bioDevicesCanvasModel
//     }
//     ListModel {
//         id: bioDevicesSourceModel
//         ListElement { modelData: "9XUAS1.png"}
//         ListElement { modelData: "CMV1.png"}

//         function getModelIndex(value) {
//             for (var i = 0; i < this.count; i++) {
//                 if (this.get(i).modelData === value) {
//                     return i;
//                 }
//             }
//             return -1;
//         }
//     }
//     Column {
//         anchors.fill: parent

//         Rectangle {
//             color: "#bdbd68"
//             width: parent.width
//             height: 0.3*parent.height
//             Row {
//                 anchors.fill: parent
//                 Rectangle {
//                     width: 0.5*parent.width
//                     height: parent.height
//                     Item {
//                         anchors.fill: parent
//                         Rectangle {
//                             width: 0.3* parent.width
//                             height: parent.height
//                             color: "gray"
//                             DropArea {
//                                 anchors.fill: parent
//                                 onDropped: {
//                                     console.log(drop.getDataAsString("text/plain"))

//                                 }
//                             }
//                         }

//                         Rectangle {
//                             // 不锚定住, 就会乱跑
//                             anchors.centerIn: parent
//                             width: textComponent.implicitWidth + 20
//                             height: textComponent.implicitHeight + 10
//                             color: "green"
//                             radius: 5

//                             Drag.dragType: Drag.Automatic
//                             Drag.supportedActions: Qt.CopyAction
//                             Drag.mimeData: {
//                                 "text/plain": "Copied text"
//                             }

//                             Text {
//                                 id: textComponent
//                                 anchors.centerIn: parent
//                                 text: "Drag me"
//                             }

//                             DragHandler {
//                                 id: dragHandler
//                                 onActiveChanged: {
//                                     if (active) {
//                                         console.log("start")
//                                         // The grab happens asynchronously and the JavaScript function callback is invoked
//                                         // when the grab is completed.
//                                         // The callback takes one argument, which is the result of the grab operation;
//                                         // an ItemGrabResult object
//                                         parent.grabToImage(function (result) {
//                                             parent.Drag.imageSource = result.url
//                                             parent.Drag.active = true
//                                         })
//                                     } else {
//                                         parent.Drag.active = false
//                                     }
//                                 }

//                                 Drag.onDragStarted: {
//                                     // console.log("start")
//                                 }
//                             }
//                         }
//                     }
//                 }
//                 Rectangle {
//                     color: "#7daba9"
//                     width: 0.5*parent.width
//                     height: parent.height

//                     Row {
//                         anchors.fill: parent
//                         Rectangle {
//                             width: 0.5*parent.width
//                             height: parent.height
//                             color: "#42bda1"
//                             DropArea {
//                                 anchors.fill: parent
//                                 onDropped: {
//                                     console.log("dropped")
//                                 }
//                             }
//                         }
//                         Rectangle {
//                             width: 0.5*parent.width
//                             height: parent.height
//                             Rectangle {
//                                 id: dragTarget
//                                 width: 60
//                                 height: 30
//                                 color: "red"
//                                 anchors.centerIn: parent

//                                 // states: State {
//                                 //     when: btnDragArea.drag.active
//                                 //     AnchorChanges {
//                                 //         target: dragTarget.parent
//                                 //         anchors {
//                                 //             verticalCenter: undefined
//                                 //             horizontalCenter: undefined
//                                 //         }
//                                 //     }
//                                 // }

//                                 Text {
//                                     anchors.fill: parent
//                                     anchors.centerIn: parent

//                                     x: 100
//                                     y: 100
//                                     text: "drag"
//                                 }

//                                 Drag.active: btnDragArea.drag.active
//                                 // 指定这个才会接受到Drop事件
//                                 Drag.dragType: Drag.Automatic
//                                 Drag.hotSpot.x: width/2
//                                 Drag.hotSpot.y: height/2

//                                 Drag.onActiveChanged: {
//                                     // console.log("Active changed..")
//                                 }

//                                 Drag.onDragStarted: {
//                                     // only work when using Drag.Automatic or explicitly calling startDrag()
//                                     console.log("Drag started..")
//                                     dragTarget.grabToImage(function(result) {
//                                         dragTarget.Drag.imageSource = result.url
//                                         dragTarget.Drag.active = true
//                                     })
//                                 }

//                                 Drag.onDragFinished: {
//                                     // only work when using Drag.Automatic or explicitly calling startDrag()
//                                     console.log("Drag finished!")
//                                 }

//                                 MouseArea {
//                                     id: btnDragArea
//                                     anchors.fill: parent
//                                     drag.target: dragTarget
//                                     drag.onActiveChanged: {
//                                         if(active){
//                                             console.log("drag started")
//                                         }
//                                     }
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         }

//         Rectangle {
//             id: canvas
//             color: "yellow"
//             width: parent.width
//             height: 0.3*parent.height
//             DropArea {
//                 id: dropArea
//                 anchors.fill: parent
//                 onDropped: {
//                     var modelData = drop.getDataAsString("text/plain")
//                     console.log(modelData+" dropped")
//                     bioDevicesCanvasModel.append({"modelData": modelData, "posX": drop.x, "posY": drop.y})
//                     console.log(Utils._QObjectToJson(bioDevicesCanvasModel))
//                 }
//             }
//         }
//         Rectangle {
//             // id: source
//             color: "#cc83d7"
//             width: parent.width
//             height: 0.4*parent.height

//             Flow {
//                 id: bioDevicesSourceFlow
//                 // anchors.fill: parent
//                 // anchors.margins: 10
//                 width: parent.width-10
//                 height: parent.height-10
//                 spacing: 10

//                 Repeater {
//                     model: bioDevicesSourceModel
//                     Rectangle {
//                         width: img.implicitWidth; height: img.implicitHeight
//                         // anchors.fill: parent
//                         // color: "transparent"
//                         color: "red"
//                         // Drag.dragType 设置为Drag.Automatic时要手动指定下面的
//                         // Drag.active: dragArea.drag.active
//                         Drag.dragType: Drag.Automatic
//                         Drag.mimeData: {"text/plain": modelData}
//                         // Drag.hotSpot.x: width
//                         // Drag.hotSpot.y: height
//                         // Drag.supportedActions: Qt.CopyAction

//                         // Drag.imageSource: img.source
//                         // MouseArea {
//                         //     id: dragArea
//                         //     anchors.fill: parent
//                         //     drag.target: parent
//                         // }
//                         DragHandler {
//                             // 默认parent, 如果为其他, 则接受当前区域鼠标事件, 但是控制target区域
//                             // target: parent
//                             snapMode: DragHandler.SnapAlways
//                             onActiveChanged: {
//                                 if (active) {
//                                     // Repeater语境下可以使用modelData(包括自定义属性)
//                                     var idx = bioDevicesSourceModel.getModelIndex(modelData)
//                                     console.log(modelData+ " start, index: "+idx+", "+Utils._QObjectToJson(bioDevicesSourceModel.get(idx)))
//                                     // bioDevicesSourceModel.insert(idx, bioDevicesSourceModel.get(idx))
//                                     // The grab happens asynchronously and the JavaScript function callback is invoked
//                                     // when the grab is completed.
//                                     // The callback takes one argument, which is the result of the grab operation;
//                                     // an ItemGrabResult object
//                                     parent.grabToImage(function(result) {
//                                         parent.Drag.imageSource = result.url
//                                         parent.Drag.active = true
//                                     })
//                                 } else {
//                                     parent.Drag.active = false
//                                 }
//                             }
//                         }

//                         Image {
//                             id: img
//                             source: "Genetic_Element/"+modelData
//                             width: 100; height: 40
//                             fillMode: Image.PreserveAspectFit
//                         }
//                     }
//                 }
//             }
//         }
//     }


// }

// Window {
//     visible: true
//     width: 800
//     height: 600

//     // 定义一个组件，用于创建矩形
//     Component {
//         id: dynamicRectangle
//         Rectangle {
//             x: posX
//             y: posY
//             width: 50
//             height: 50
//             color: "red"
//         }
//     }

//     // 创建一个 MouseArea 用于处理拖放事件
//     Rectangle {
//         width: parent.width
//         height: parent.height
//         color: "lightgray"

//         MouseArea {
//             id: dropArea
//             anchors.fill: parent
//             acceptedButtons: Qt.LeftButton

//             // 定义一个 ListModel 用于存储动态创建的矩形信息
//             ListModel {
//                 id: rectangleModel
//             }

//             // 使用 Repeater 来显示动态创建的矩形
//             Repeater {
//                 model: rectangleModel
//                 delegate: dynamicRectangle
//             }

//             // 处理鼠标释放事件
//             onPressed: {
//                 // 获取鼠标释放的位置
//                 var posX = mouse.x
//                 var posY = mouse.y

//                 // 向模型添加一个新项，包括 x 和 y 坐标
//                 rectangleModel.append({"posX": posX, "posY": posY})
//             }
//         }
//     }
// }


// Item {
//     width: 640
//     height: 480

//     Rectangle {
//         id: feedback
//         border.color: "red"
//         width: Math.max(10, handler.centroid.ellipseDiameters.width)
//         height: Math.max(10, handler.centroid.ellipseDiameters.height)
//         radius: Math.max(width, height) / 2
//         visible: handler.active
//     }

//     DragHandler {
//         id: handler
//         target: feedback
//     }
// }

// Item {
//     width: 200
//     height: 200

//     Rectangle {
//         width: 50
//         height: 50
//         color: "yellow"
//         DropArea {
//             anchors.fill: parent
//             onDropped: {
//                 console.log(drop.getDataAsString("text/plain"))

//             }
//         }
//     }

//     Rectangle {
//         // 不锚定住, 就会乱跑
//         anchors.centerIn: parent
//         width: textComponent.implicitWidth + 20
//         height: textComponent.implicitHeight + 10
//         color: "green"
//         radius: 5

//         Drag.dragType: Drag.Automatic
//         Drag.supportedActions: Qt.CopyAction
//         Drag.mimeData: {
//             "text/plain": "Copied text"
//         }

//         Text {
//             id: textComponent
//             anchors.centerIn: parent
//             text: "Drag me"
//         }

//         DragHandler {
//             id: dragHandler
//             onActiveChanged: {
//                 if (active) {
//                     console.log("start")
//                     // The grab happens asynchronously and the JavaScript function callback is invoked
//                     // when the grab is completed.
//                     // The callback takes one argument, which is the result of the grab operation;
//                     // an ItemGrabResult object
//                     parent.grabToImage(function (result) {
//                         parent.Drag.imageSource = result.url
//                         parent.Drag.active = true
//                     })
//                 } else {
//                     parent.Drag.active = false
//                 }
//             }

//             Drag.onDragStarted: {
//                 // console.log("start")
//             }
//         }
//     }
// }



// Window {
//     visible: true
//     width: 640
//     height: 480

//     // 定义一个拖拽控件的原型
//     Component {
//         id: dragComponent
//         Rectangle {
//             width: itemToBeDragDrop.width
//             height: itemToBeDragDrop.height
//             color: itemToBeDragDrop.color
//             border.color: "black"
//             opacity: 0.7
//         }
//     }

//     // 拖拽源区域
//     Rectangle {
//         id: dragFrom
//         width: parent.width / 2
//         height: parent.height
//         color: "lightgray"

//         // 可拖拽的控件
//         Rectangle {
//             id: itemToBeDragDrop
//             width: 100
//             height: 100
//             color: "blue"
//             border.color: "black"
//             anchors.centerIn: parent

//             MouseArea {
//                 id: dragArea
//                 anchors.fill: parent
//                 drag.target: parent

//                 onReleased: {
//                     if (drag.active) {
//                         drag.drop()
//                     }
//                 }

//                 onPressAndHold: {
//                     // 开始拖拽时创建新的组件
//                     drag.startDragAndDrop(Qt.MoveAction)
//                 }
//                 // When using Drag.Automatic you should also define mimeData and
//                 // bind the active property to the active property of
//                 // MouseArea : MouseArea::drag.active
//                 Drag.active: dragArea.drag.active
//                 Drag.dragType: Drag.Automatic
//                 Drag.source: parent
//                 Drag.hotSpot.x: dragArea.width / 2
//                 Drag.hotSpot.y: dragArea.height / 2
//                 // Drag.sourceComponent: dragComponent
//             }
//         }]
//     }

//     // 接受拖拽的区域
//     Rectangle {
//         id: dropAt
//         width: parent.width / 2
//         height: parent.height
//         color: "lightgreen"
//         anchors.right: parent.right

//         DropArea {
//             anchors.fill: parent
//             onDropped: {
//                 console.log("drop")
//                 // 复制并放置拖拽的控件
//                 // if (drag.sourceComponent === dragComponent) {
//                 //     var newItem = drag.sourceComponent.createObject(dropAt, {
//                 //         x: drag.hotSpot.x,
//                 //         y: drag.hotSpot.y
//                 //     })
//                 //     newItem.x = dragArea.mouseX - newItem.width / 2
//                 //     newItem.y = dragArea.mouseY - newItem.height / 2
//                 // }
//             }
//         }
//     }
// }

// Rectangle {
//     color: "yellow"
//     width: 100; height: 100

//     MouseArea {
//         anchors.fill: parent
//         onClicked: console.log("clicked yellow")
//     }

//     Rectangle {
//         color: "blue"
//         width: 50; height: 50

//         MouseArea {
//             anchors.fill: parent
//             propagateComposedEvents: true
//             onClicked: {
//                 console.log("clicked blue")
//                 mouse.accepted = false
//             }
//         }
//     }
//     MouseArea {
//         anchors.fill: parent
//         propagateComposedEvents: true
//         onClicked: {
//             console.log("clicked top")
//             mouse.accepted = false
//         }
//     }
// }

// Rectangle {
//     width: 480
//     height: 320
//     Rectangle {
//         x: 30; y: 30
//         width: 300; height: 240
//         color: "lightsteelblue"

//         MouseArea {
//             anchors.fill: parent
//             drag.target: parent;
//             drag.axis: "XAxis"
//             drag.minimumX: 30
//             drag.maximumX: 150
//             drag.filterChildren: true

//             Rectangle {
//                 color: "yellow"
//                 x: 50; y : 50
//                 width: 100; height: 100
//                 MouseArea {
//                     anchors.fill: parent
//                     onClicked: console.log("Clicked")
//                 }
//             }
//             onClicked: console.log("parent Clicked")
//         }
//     }
// }

