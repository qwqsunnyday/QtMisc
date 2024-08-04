import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "DebugUtils.js" as DebugUtils

Window {
    id: root
    width: 640
    height: 480
    color: "#ffffff"
    visible: true
    ListModel {
        id: bioDevicesCanvasModel
    }
    ListModel {
        id: bioDevicesSourceModel
        ListElement { modelData: "9XUAS1.png"}
        ListElement { modelData: "CMV1.png"}

        function getModelIndex(value) {
            for (var i = 0; i < this.count; i++) {
                if (this.get(i).modelData === value) {
                    return i;
                }
            }
            return -1;
        }
    }
    Column {
        anchors.fill: parent

        Rectangle {
            color: "#bdbd68"
            width: parent.width
            height: 0.3*parent.height
            Row {
                anchors.fill: parent
                Rectangle {
                    width: 0.5*parent.width
                    height: parent.height
                    Item {
                        anchors.fill: parent
                        Rectangle {
                            width: 0.3* parent.width
                            height: parent.height
                            color: "gray"
                            DropArea {
                                anchors.fill: parent
                                onDropped: {
                                    console.log(drop.getDataAsString("text/plain"))

                                }
                            }
                        }

                        Rectangle {
                            // 不锚定住, 就会乱跑
                            anchors.centerIn: parent
                            width: textComponent.implicitWidth + 20
                            height: textComponent.implicitHeight + 10
                            color: "green"
                            radius: 5

                            Drag.dragType: Drag.Automatic
                            Drag.supportedActions: Qt.CopyAction
                            Drag.mimeData: {
                                "text/plain": "Copied text"
                            }

                            Text {
                                id: textComponent
                                anchors.centerIn: parent
                                text: "Drag me"
                            }

                            DragHandler {
                                id: dragHandler
                                onActiveChanged: {
                                    if (active) {
                                        console.log("start")
                                        // The grab happens asynchronously and the JavaScript function callback is invoked
                                        // when the grab is completed.
                                        // The callback takes one argument, which is the result of the grab operation;
                                        // an ItemGrabResult object
                                        parent.grabToImage(function (result) {
                                            parent.Drag.imageSource = result.url
                                            parent.Drag.active = true
                                        })
                                    } else {
                                        parent.Drag.active = false
                                    }
                                }

                                Drag.onDragStarted: {
                                    // console.log("start")
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    color: "#7daba9"
                    width: 0.5*parent.width
                    height: parent.height

                    Row {
                        anchors.fill: parent
                        Rectangle {
                            width: 0.5*parent.width
                            height: parent.height
                            color: "#42bda1"
                            DropArea {
                                anchors.fill: parent
                                onDropped: {
                                    console.log("dropped")
                                }
                            }
                        }
                        Rectangle {
                            width: 0.5*parent.width
                            height: parent.height
                            Rectangle {
                                id: dragTarget
                                width: 60
                                height: 30
                                color: "red"
                                anchors.centerIn: parent

                                // states: State {
                                //     when: btnDragArea.drag.active
                                //     AnchorChanges {
                                //         target: dragTarget.parent
                                //         anchors {
                                //             verticalCenter: undefined
                                //             horizontalCenter: undefined
                                //         }
                                //     }
                                // }

                                Text {
                                    anchors.fill: parent
                                    anchors.centerIn: parent

                                    x: 100
                                    y: 100
                                    text: "drag"
                                }

                                Drag.active: btnDragArea.drag.active
                                // 指定这个才会接受到Drop事件
                                Drag.dragType: Drag.Automatic
                                Drag.hotSpot.x: width/2
                                Drag.hotSpot.y: height/2

                                Drag.onActiveChanged: {
                                    // console.log("Active changed..")
                                }

                                Drag.onDragStarted: {
                                    // only work when using Drag.Automatic or explicitly calling startDrag()
                                    console.log("Drag started..")
                                    dragTarget.grabToImage(function(result) {
                                        dragTarget.Drag.imageSource = result.url
                                        dragTarget.Drag.active = true
                                    })
                                }

                                Drag.onDragFinished: {
                                    // only work when using Drag.Automatic or explicitly calling startDrag()
                                    console.log("Drag finished!")
                                }

                                MouseArea {
                                    id: btnDragArea
                                    anchors.fill: parent
                                    drag.target: dragTarget
                                    drag.onActiveChanged: {
                                        if(active){
                                            console.log("drag started")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: canvas
            color: "yellow"
            width: parent.width
            height: 0.3*parent.height
            DropArea {
                id: dropArea
                anchors.fill: parent
                onDropped: {
                    var modelData = drop.getDataAsString("text/plain")
                    console.log(modelData+" dropped")
                    bioDevicesCanvasModel.append({"modelData": modelData, "posX": drop.x, "posY": drop.y})
                    console.log(DebugUtils._QObjectToJson(bioDevicesCanvasModel))
                }
            }
        }
        Rectangle {
            // id: source
            color: "#cc83d7"
            width: parent.width
            height: 0.4*parent.height

            Flow {
                id: bioDevicesSourceFlow
                // anchors.fill: parent
                // anchors.margins: 10
                width: parent.width-10
                height: parent.height-10
                spacing: 10

                Repeater {
                    model: bioDevicesSourceModel
                    Rectangle {
                        width: img.implicitWidth; height: img.implicitHeight
                        // anchors.fill: parent
                        // color: "transparent"
                        color: "red"
                        // Drag.dragType 设置为Drag.Automatic时要手动指定下面的
                        // Drag.active: dragArea.drag.active
                        Drag.dragType: Drag.Automatic
                        Drag.mimeData: {"text/plain": modelData}
                        // Drag.hotSpot.x: width
                        // Drag.hotSpot.y: height
                        // Drag.supportedActions: Qt.CopyAction

                        // Drag.imageSource: img.source
                        // MouseArea {
                        //     id: dragArea
                        //     anchors.fill: parent
                        //     drag.target: parent
                        // }
                        DragHandler {
                            // 默认parent, 如果为其他, 则接受当前区域鼠标事件, 但是控制target区域
                            // target: parent
                            snapMode: DragHandler.SnapAlways
                            onActiveChanged: {
                                if (active) {
                                    // Repeater语境下可以使用modelData(包括自定义属性)
                                    var idx = bioDevicesSourceModel.getModelIndex(modelData)
                                    console.log(modelData+ " start, index: "+idx+", "+DebugUtils._QObjectToJson(bioDevicesSourceModel.get(idx)))
                                    // bioDevicesSourceModel.insert(idx, bioDevicesSourceModel.get(idx))
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
            }
        }
    }


}

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

