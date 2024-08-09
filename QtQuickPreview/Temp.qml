import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "Utils.js" as Utils

/*
# 文件概述

本文件主要包括:
    - JS回调函数与闭包作用域
    - grabToImage时机: onEntered
    - Drag.dragType: Drag.Automatic情况下的平滑拖拽处理
    - 外部访问Repeater和Loader的元素
    - dumpItemTree
    - 网格叠加层
    - 各种防忘注释

## QML Drag&Drop

拖拽主要关注两点: 事件处理时机和数据的传输

坑点:
    1. QML中有两种常用的Drag类型, Drag.Automatic和Drag.Internal, 两者区别可以说非常大, 但是官方文档描述十分含糊

QML中, 拖拽事件通过 MouseArea (或 DragHandler )处理, 使用 DropArea 接受数据

## Drag.Internal类型Drag

- 旧版拖拽

    (qml doc: start backwards compatible drags automatically)

- 侧重dragItem的坐标可变

    Drag.Internal为默认值, 侧重于指定dragItem的坐标可变:

    QML中继承自 Item 的元素(dragItem)都可以通过简单地将元素置为MouseArea的drag.target来使本体(dragItem)变得可拖动(由于拖拽需要修改dragItem的坐标和宽高, 因此dragItem不要用锚布局, 比如x锚定住了, 就只能在y拖动了; 见qml book: src/ch04-qmlstart/anchors)

- DropArea::dropped()需额外配置:

    要自己通过dragItem.Drag.start()发送和dragItem.Drag.drop()结束一段drag events, 这样才能在 DropArea 中使用onDropped()处理dropped()信号

- 自动处理 Drag.active:

    dragItem.Drag.start()后为true, dragItem.Drag.drop()后为false

- 默认在parent层级内拖动:

    跨区域可能需要修改parent的z stack(见qml doc: Item.z; 本文档: canvas.z)

## Drag.Automatic类型Drag

- 新版拖拽

    更加一般的拖拽处理, 可以跨窗口传输mime数据

- 侧重"拖拽"动作与数据传输

    与Drag.Internal的主要区别在于, Drag.Automatic根本不会试图改变dragItem的坐标, 只关注鼠标的Drag和Drop动作, 会自发送 DropArea::dropped()信号

- 自动处理

- 需要手动处理拖拽时的缩略图


## 本文件的拖拽实现思路

## 其他资源

1. 文档: MouseArea; Drag; DropArea; DragHandler; DragEvent
2. 官方Example: Qt Quick Examples - Drag and Drop.
3. qml book src/ch04-qmlstart/anchors

*/

Item {
    width: 500
    height: 400
    visible: true
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: canvas
            Layout.preferredHeight: 0.3* parent.height
            Layout.fillWidth: true
            color: "yellow"
            z: 1
            ListModel {
                id: dropModel
                // 由于对象可能随意实例化, 因此持久化信息必须保存在model中!!!
                // ListElement 本身也是ListModel
                // 使用Object承载数据时, 是副本, 无法修改
                // ListModel等可以进行绑定, 否则需要自行在C++/Python实现
                // sequenceIndex 可以通过parent.parent.index访问(当stateType=="inSequence")
                // ListElement {
                //     uuid: 0
                //     sequenceIndex: -1
                //     modelData: ""
                //     posX: 0
                //     posY: 0
                //     stateType: "" inSource dropped inSequence
                //     description: ""
                //     info: ""
                // }
            }

            ListModel {
                id: sequenceModel
                // ListElement {
                //     uuid: 0
                //     droppedItemModel: undefined
                //     len: 0
                //     posX: 0
                //     posY: 0
                // }
            }

            Repeater {
                model: sequenceModel


                delegate: Rectangle {
                    id: sequenceItem
                    color: "pink"

                    required property var droppedItemModel
                    required property int uuid
                    required property int index
                    required property int posX
                    required property int posY

                    height: 120
                    width: droppedItemModel.count*100
                    x: posX
                    y: posY
                    Grid {
                        rows: 1
                        columns: droppedItemModel.count
                        anchors.fill: parent

                        Repeater {
                            model: droppedItemModel

                            delegate: dragCompenent
                        }

                    }
                    MouseArea {
                        anchors.fill: parent
                        drag.target: sequenceItem
                    }
                }
            }
            Repeater {
                model: dropModel

                delegate: dragCompenent
            }

            DropArea {
                id: canvasDropArea
                anchors.fill: parent
                // 接受
                keys: ['modelData']
                onEntered: {
                    // console.log("entered canvasDropArea")
                }
                onPositionChanged: {
                    // console.log("pos changed")
                    // console.log(drag.x+" "+drag.y)
                }
                // DropArea还具有drag.source属性
                onDropped: { // canvasDropArea
                    // dropped(DragEvent drop)
                    // 可以使用drop.source(参数)或drag.source(属性)访问dragItem
                    console.log("dropped at:")
                    console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")
                    // if (drop.hasText) {
                    //     console.log("Drop Keys: " + drop.keys)
                    //     console.log("Drop Text: " + drop.text)
                    // }
                    // console.log(Utils._QObjectToJson(drop.source.Drag.mimeData))
                    // dropModel.append({"uuid": Utils.uuid(),"modelData": drop.source.Drag.mimeData["modelData"], "posX": drop.x - drop.source.Drag.hotSpot.x, "posY": drop.y - drop.source.Drag.hotSpot.y})
                    let upItem = drop.source
                    dropModel.append({
                        "uuid": Utils.uuid(),
                        "sequenceIndex": -1,
                        "modelData": upItem.modelData,
                        "posX": drop.x - drop.source.Drag.hotSpot.x,
                        "posY": drop.y - drop.source.Drag.hotSpot.y,
                        "stateType": "inSource",
                        "description": "default description",
                        "info": ""
                    })
                }
            }

            Rectangle {
                color: "Orange"
                height: parent.height
                width: parent.width/8
                Text {
                    text: "Nested Drop Area"
                    anchors.centerIn: parent
                }
                DropArea {
                    id: nestedDropArea
                    anchors.fill: parent
                    onDropped: {
                        console.log("dropped in nestedDropArea")
                    }
                    onEntered: {
                        console.log("entered nestedDropArea")
                    }
                }
            }
        }
        Rectangle {
            id: rectangle
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "red"
            z: 0
            Component {
                id: dragCompenent
                Rectangle {
                    id: dragItem

                    // 要手动加才可以访问index附加属性
                    required property int index
                    required property int uuid
                    required property int posX
                    required property int posY
                    required property int sequenceIndex
                    required property string modelData
                    required property string stateType
                    required property string description
                    required property var info

                    function toString() {
                        return JSON.stringify({"uuid":uuid, "posX":posX, "posY":posX, "modelData":modelData, "stateType":stateType, "description":description, "info":info})
                    }

                    x: posX
                    y: posY
                    width: 100
                    height: 100
                    color: "black"
                    objectName: "description of dragItem"

                    Rectangle {
                        id: connectionArea
                        width: 60
                        height: 60
                        color: "gray"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        DropArea {
                            id: connectionDropArea
                            anchors.fill: parent
                            onEntered: {
                                // console.log("entered connectionDropArea")
                            }

                            onDropped: {
                                console.log("connectionDropArea dropped:")
                                // console.log("drag.source.Drag.mimeData")
                                // console.log(Utils._QObjectToJson(drag.source.Drag.mimeData))
                                // console.log("dragItem.Drag.mimeData:")
                                // console.log(Utils._QObjectToJson(dragItem.Drag.mimeData))

                                var upItem = drag.source
                                var downItem = dragItem
                                console.log(downItem.index)

                                var currentSequenceIndex = downItem.sequenceIndex
                                console.log(currentSequenceIndex)
                                if(currentSequenceIndex !==-1){
                                    // down已经在一个序列内了
                                    console.log("down已经在一个序列内了")
                                    let currentSequenceIndex = downItem.parent.parent.index
                                    dropModel.get(upItem.index).sequenceIndex=currentSequenceIndex
                                    sequenceModel.get(currentSequenceIndex).droppedItemModel.append(dropModel.get(upItem.index))

                                    dropModel.remove(upItem.index)
                                }else{
                                    // 全新的两个元素
                                    console.log("全新的两个元素")
                                    dropModel.get(upItem.index).sequenceIndex=sequenceModel.count
                                    dropModel.get(downItem.index).sequenceIndex=sequenceModel.count
                                    sequenceModel.append({
                                        uuid: Utils.uuid(),
                                        droppedItemModel: [dropModel.get(downItem.index), dropModel.get(upItem.index)],
                                        posX: dragItem.x,
                                        posY: dragItem.y
                                    })

                                    dropModel.remove(upItem.index)
                                    dropModel.remove(downItem.index)
                                }


                                // console.log(Utils.modelToJSON(sequenceModel))

                            }
                        }
                    }

                    Text {
                        id: txt
                        // anchors.fill: parent
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: parent.width/6
                        text: parent.Drag.mimeData["modelData"]+"\nuuid: "+uuid+"\nDrag: "+dragItem.Drag.active+"\n"+dragItem.Drag.dragType
                    }


                    // opacity: Drag.active ? 0.8 : 1

                    PropertyAnimation {
                        id: dragItemOpacityAnimation
                        target: dragItem
                        property: "opacity"
                        from: 1.0
                        to: 0.8
                        easing.type : Easing.OutExpo
                        duration: 200
                    }
                    PropertyAnimation {
                        id: dragItemOpacityAnimationReversed
                        target: dragItem
                        property: "opacity"
                        from: 0.8
                        to: 1.0
                        easing.type : Easing.OutExpo
                        duration: 200
                    }
                    Connections {
                        target: dragArea
                        function onEntered (mouse) {
                            dragItemOpacityAnimation.start()
                        }
                        function onExited (mouse) {
                            dragItemOpacityAnimationReversed.start()
                        }
                    }


                    // 一般用于跨应用, dragItem可超出窗口范围, 使用mimeData传递数据
                    // 需要自己处理imageSource同时绑定Drag.active: dragArea.drag.active(可选)
                    // 这里为了平滑, 自定义了dragItem.Drag.hotSpot并在pressed时设置Drag.active=true
                    // Drag.active: dragArea.drag.active
                    Drag.dragType: parent == canvas ? Drag.Internal : Drag.Automatic
                    // 默认, 在窗口内进行
                    // Drag.dragType: Drag.Internal
                    Drag.mimeData: {
                        'uuid': (typeof(uuid)=="undefined") ? "0" : uuid,
                        'modelData': (typeof(modelData)=="undefined") ? "Default" : modelData,
                        'type': parent == canvas ? "Dropped" : "ToBeDrop"
                    }
                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        drag.target: dragItem
                        hoverEnabled: true
                        onPressed: {
                            console.log("startDrag")
                            console.log(mouse.x+" "+mouse.y)
                            dragItem.Drag.hotSpot.x = mouse.x
                            dragItem.Drag.hotSpot.y = mouse.y
                            // 问题在于, 由于是异步调用, 点击时不会立即生成图像, 第二次点击才可
                            // dragItem.grabToImage(function(result) {
                            //     dragItem.Drag.imageSource = result.url
                            //     console.log(dragItem.Drag.mimeData["modelData"])
                            //     imageDialog.loadImage(result.url)
                            // })
                            dragItem.Drag.active = true;
                            // 非常奇怪...因为Drag.start()之后dragItem.Drag.active会设置为true
                            // dragItem.Drag.start()
                            // TODO 注释后会解决无法识别Drop区域的问题, 但是小概率引入无法响应拖拽的问题
                            // dragItem.Drag.startDrag();
                            dragItem.z = 100
                            console.log(JSON.stringify(dragItem.Drag.mimeData))
                        }
                        onEntered: {
                            // 最终解决办法: hoverEnabled: true然后onEntered中抓取
                            dragItem.grabToImage(function(result) {
                                dragItem.Drag.imageSource = result.url
                                // console.log(dragItem.Drag.mimeData["modelData"])
                                // imageDialog.loadImage(result.url)
                            })
                            // console.log(dragItem.parent == canvas ? "parent == canvas":"0")
                            // console.log(JSON.stringify(dragItem.Drag.mimeData))
                            // console.log("z: "+dragItem.z)
                        }

                        onReleased: {
                            console.log("released");
                            // console.log(Utils.modelToJSON(dropModel))
                            // console.log(Utils.modelToJSON(dragModel))
                            dragItem.Drag.drop();
                            dragItem.z = 0
                        }
                        onClicked: {
                            console.log(dragItem.toString())
                        }
                    }
                    Component.onCompleted: {
                        // console.log("rootWindow.visible: "+root.visible)
                        // console.log("Component.onCompleted - 3")
                    }
                }
            }
            // Loader {
            //     id: dragLoader
            //     sourceComponent: dragCompenent
            //     onLoaded: {
            //         // 此时窗口仍然不可见
            //         // console.log("rootWindow.visible: "+root.visible)
            //         // 使用item属性访问装载的元素
            //         // console.log("onLoaded - 1"+ " objectName: "+item.objectName)
            //         // 这样会失败
            //         // item.grabToImage(function(result) {
            //         //     item.Drag.imageSource = result.url
            //         //     // dragItem.Drag.active = true
            //         // })
            //         // TODO XXX
            //         setSource(dragCompenent, {"uuid": Utils.uuid(), "modelData": "data: None" })
            //     }
            // }
            RowLayout {
                anchors.fill: parent
                Rectangle {
                    color: "red"
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent
                        ListView {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            model: dropModel
                            delegate: Text {
                                text: "uuid: "+uuid+" modelData: "+modelData
                                font.pixelSize: 16
                            }
                        }
                        ListView {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            model: sequenceModel
                            delegate: Text {
                                text: "index: "+index+" droppedItemModel.count: "+droppedItemModel.count + " posX: "+posX + " posY: "+posY
                                font.pixelSize: 16
                            }
                        }
                    }

                }

                Rectangle {
                    color: "#806be7"
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ListModel {
                        id: dragModel
                        // ListElement {
                        //     uuid: undefined
                        //     modelData: undefined
                        // }
                    }

                    Flow {
                        clip: true
                        anchors.fill: parent
                        spacing: 20
                        Repeater {
                            id: dragRepeater
                            model: dragModel
                            delegate: dragCompenent
                            // 或者
                            // delegate: Component {
                                // ...
                            // }
                            // 但是不能是Loader

                            Component.onCompleted: {
                                for (let i = 0; i < 3; i++) {
                                    dragModel.append({
                                        "uuid": Utils.uuid(),
                                        "sequenceIndex": -1,
                                        "modelData": "data: " + i,
                                        "posX": 0,
                                        "posY": 0,
                                        "stateType": "inSource",
                                        "description": "default description",
                                        "info": ""
                                    })
                                }
                                // console.log(dragModel.get(0).uuid)
                                // console.log("rootWindow.visible: "+root.visible)
                                // console.log("Component.onCompleted - Repeater")
                                // 使用itemAt()获取元素
                                // console.log("Accessing property of repeated item using itemAt(): "+itemAt(0).objectName)

                                // deprecated:
                                // for (let i = 0; i < count; i++) {
                                //     itemAt(i).grabToImage(function(result) {
                                //         // 注意, 由于是异步, 导致本回调函数可能在for执行完毕后才执行, 此时i已经变成了count
                                //         // 如果使用var定义i, 则回调函数始终捕获的是最后的i; 使用let(ES6, 2015)定义块级变量或使用IIFE捕获i可以解决
                                //         // 回调函数不会有错误提示
                                //         // console.log(i)
                                //         itemAt(i).Drag.imageSource = result.url
                                //         // imageDialog.loadImage(result.url)
                                //     })
                                // }

                                /*
                                for (let i = 0; i < count; i++) {
                                    (function (i_arg)
                                        {
                                            itemAt(i_arg).grabToImage(function(result) {
                                                // 注意, 由于是异步, 导致本回调函数可能在for执行完毕后才执行, 此时i已经变成了count
                                                // 如果使用var定义i, 则回调函数始终捕获的是最后的i; 使用let(ES6, 2015)定义块级变量或使用IIFE捕获i可以解决
                                                // 回调函数不会有错误提示
                                                console.log(i_arg)
                                                itemAt(i_arg).Drag.imageSource = result.url
                                                imageDialog.loadImage(result.url)
                                            })
                                        }
                                    )(i)
                                    // IIFE, 立即捕获i并赋给i_arg
                                }
                                */

                                /* JS经典
                                // https://blog.csdn.net/zzzhhhy/article/details/126463776
                                for (var i = 1; i <= 5; i++) {
                                    setTimeout(function timer() {
                                        console.log(i)
                                    }, 0)
                                }  // 6 6 6 6 6 6
                                为什么会全部输出6？ 如何改进， 让它输出1， 2， 3， 4， 5？
                                */
                            }
                        }
                        Component.onCompleted: {
                            // console.log("rootWindow.visible: "+root.visible)
                            // console.log("Component.onCompleted - Out Repeater")
                            // Repeater外使用itemAt()获取元素
                            // console.log("Accessing property of repeated item using itemAt(): "+dragRepeater.itemAt(0).objectName)
                        }
                    }
                }
            }

            DropArea {
                anchors.fill: parent
                // keys: ["discard"]
                onEntered: {
                    console.log("entered rectangle")
                }

                onDropped: {
                    // dropped(DragEvent drop)
                    // 可以使用drop.source(参数)或drag.source(属性)访问dragItem
                    console.log("dropped at rectangle")
                    console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")
                    if (drop.hasText) {
                        console.log("Drop Keys: " + drop.keys)
                        console.log("Drop Text: " + drop.text)
                    }
                    console.log(Utils._QObjectToJson(drop.source.Drag.mimeData))
                    if (drag.source.Drag.mimeData["type"] === "Dropped") {
                        console.log("current dropModel: ")
                        console.log(Utils.modelToJSON(dropModel))
                        let targetIndex = Utils.getModelIndex(dropModel, "uuid", drag.source.Drag.mimeData["uuid"])
                        console.log("targetIndex: "+targetIndex)
                        dropModel.remove(targetIndex)
                    }
                }
            }

            Component.onCompleted: {
                // console.log("rootWindow.visible: "+root.visible)
                // console.log("Component.onCompleted - 4")
                // Loader外使用item属性访问装载的元素
                // console.log("Accessing property of repeated item using item: "+dragLoader.item.objectName)
                // deprecated:
                // dragLoader.item.grabToImage(function(result) {
                //     dragLoader.item.Drag.imageSource = result.url
                //     // imageDialog.loadImage(result.url)
                //     // dragItem.Drag.active = true
                // })
            }
        }

    }

    // 定义一个弹窗，用于显示加载的图像
    Dialog {
        id: imageDialog
        width: dialogImage.implicitWidth
        height: dialogImage.implicitHeight
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: Image {
            id: dialogImage
            anchors.centerIn: parent
            // fillMode: Image.PreserveAspectFit
            // width: parent.width
            height: parent.height
        }
        function loadImage(imageUrl) {
            dialogImage.source = imageUrl
            imageDialog.open()
        }
    }
    WindowFrameRate {
        targetWindow: Window.window
    }
}


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

