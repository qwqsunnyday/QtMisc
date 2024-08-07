import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 2.15

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

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: canvas
            height: 0.3*parent.height
            width: parent.width
            color: "yellow"
            z: 1
            ListModel {
                id: dropModel
                // ListElement {
                //     uuid: undefined
                //     modelData: undefined
                //     posX: 0
                //     posY: 0
                // }
            }

            Repeater {
                model: dropModel

                delegate: dragCompenent
            }

            DropArea {
                anchors.fill: parent
                // 接受
                keys: ['modelData']
                onEntered: {
                    console.log("entered")
                }
                onPositionChanged: {
                    // console.log("pos changed")
                    // console.log(drag.x+" "+drag.y)
                }
                // DropArea还具有drag.source属性
                onDropped: {
                    // dropped(DragEvent drop)
                    // 可以使用drop.source(参数)或drag.source(属性)访问dragItem
                    console.log("dropped at:")
                    console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")
                    if (drop.hasText) {
                        console.log("Drop Keys: " + drop.keys)
                        console.log("Drop Text: " + drop.text)
                    }
                    console.log(Utils._QObjectToJson(drop.source.Drag.mimeData))
                    dropModel.append({"uuid": Utils.uuid(),"modelData": drop.source.Drag.mimeData["modelData"], "posX": drop.x - drop.source.Drag.hotSpot.x, "posY": drop.y - drop.source.Drag.hotSpot.y})
                }
                Component.onCompleted: {
                    // console.log("rootWindow.visible: "+root.visible)
                    // console.log("Component.onCompleted - 1")
                }
            }
            Component.onCompleted: {
                // console.log("rootWindow.visible: "+root.visible)
                // console.log("Component.onCompleted - 2")
            }
        }
        Rectangle {
            id: rectangle
            height: 0.4*parent.height
            width: parent.width
            color: "red"
            z: 0
            Component {
                id: dragCompenent
                Rectangle {
                    id: dragItem
                    // x: posX || 30
                    // 这样会有警告, 不采用
                    x: (typeof(posX)=="undefined") ? 30 : posX
                    // y: posY || 20
                    y: (typeof(posY)=="undefined") ? 20 : posY
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
                                console.log("entered connectionDropArea")
                            }

                            onDropped: {
                                console.log("connectionDropArea dropped:")
                                console.log("drag.source.Drag.mimeData")
                                console.log(Utils._QObjectToJson(drag.source.Drag.mimeData))
                                console.log("dragItem.Drag.mimeData:")
                                console.log(Utils._QObjectToJson(dragItem.Drag.mimeData))
                            }
                        }
                    }

                    Text {
                        id: txt
                        // anchors.fill: parent
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: parent.width/6
                        text: parent.Drag.mimeData["modelData"]+"\nuuid: "+uuid+"\nDrag: "+dragItem.Drag.active+"\n"+Drag.dragType
                    }


                    opacity: Drag.active ? 0.5 : 1

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
                            // dragItem.Drag.start() 注释后会解决
                            // dragItem.Drag.startDrag();
                        }
                        onEntered: {
                            // 最终解决办法: hoverEnabled: true然后onEntered中抓取
                            dragItem.grabToImage(function(result) {
                                dragItem.Drag.imageSource = result.url
                                // console.log(dragItem.Drag.mimeData["modelData"])
                                // imageDialog.loadImage(result.url)
                            })
                        }

                        onReleased: {
                            console.log("released");
                            console.log(Utils.modelToJSON(dropModel))
                            console.log(Utils.modelToJSON(dragModel))
                            dragItem.Drag.drop();
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
                    ListView {
                        anchors.fill: parent
                        model: dropModel
                        delegate: Text {
                            id: txt
                            text: "uuid: "+uuid+" modelData: "+modelData
                            font.pixelSize: 16
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
                                    dragModel.append({"uuid": String(Utils.uuid()), "modelData": "data: " + i})
                                }

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
        Rectangle {
            id: dragInternalDemoArea
            width: parent.width
            height: 0.3*parent.height
            Text {
                text: "Drag.Internal Demo Area"
                font.pixelSize: 28
                anchors.horizontalCenter: parent.horizontalCenter
                z: 1
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    Layout.preferredWidth: parent.width/2
                    Layout.fillHeight: true
                    color: "gray"
                    ColumnLayout  {
                        id: dropCanvas
                        objectName: "canvas"
                        anchors.fill: parent
                        spacing: 0
                        Rectangle {
                            Layout.preferredHeight: parent.height/2
                            Layout.fillWidth: true
                            color: "yellow"
                            Text {
                                text: "accept keys: " + drop1.keys
                                anchors.centerIn: parent
                            }
                            DropArea {
                                id: drop1
                                anchors.fill: parent
                                keys: ['key1']
                                onDropped: {
                                    console.log("dropped")
                                    console.log(Utils._QObjectToJson(drag.source.Drag.mimeData))
                                    drag.source.anchors.horizontalCenter = undefined
                                    drag.source.anchors.verticalCenter = undefined
                                    drag.source.accepted = true
                                }
                            }
                        }
                        Rectangle {
                            Layout.preferredHeight: parent.height/2
                            Layout.fillWidth: true
                            color: "gray"
                            Text {
                                text: "accept keys: " + drop2.keys
                                anchors.centerIn: parent
                            }
                            DropArea {
                                id: drop2
                                anchors.fill: parent
                                keys: ['key2']
                                onDropped: {
                                    console.log("dropped")
                                    console.log(Utils._QObjectToJson(drag.source.Drag.mimeData))
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: parent.width/2
                    Layout.fillHeight: true
                    color: "pink"
                    Rectangle {
                        id: dragItem
                        // 不锚定住, 就会乱跑

                        // anchors.centerIn: (Drag.active || dragItem.accepted) ? undefined : parent
                        // 以上一句等价于states中进行设置
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: textComponent.implicitWidth + 20
                        height: textComponent.implicitHeight + 10
                        color: "green"

                        Drag.dragType: Drag.Internal
                        Drag.active: dragArea.drag.active
                        Drag.supportedActions: Qt.CopyAction
                        Drag.mimeData: {
                            "key1": "Copied text"
                        }
                        Drag.keys: ["key1"]
                        property bool accepted: false
                        states: State {
                            when: dragArea.drag.active || dragItem.accepted
                            AnchorChanges {
                                target: dragItem
                                anchors.horizontalCenter: undefined
                                anchors.verticalCenter: undefined
                            }
                        }
                        // Drag.active: dragArea.drag.active
                        Text {
                            id: textComponent
                            anchors.centerIn: parent
                            text: "Drag me"
                        }

                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            drag.target: parent
                            onPressed: {
                                console.log("started")
                                console.log("dragItem.Drag.active: "+dragItem.Drag.active) // false
                                dragItem.Drag.start()
                                console.log("dragItem.Drag.active: "+dragItem.Drag.active) // true
                            }
                            onReleased: {
                                // dragItem.parent = dragItem.Drag.target
                                // console.log(dragItem.Drag.target.objectName)
                                console.log("released")
                                console.log("dragItem.Drag.active: "+dragItem.Drag.active) //true
                                dragItem.Drag.drop()
                                console.log("dragItem.Drag.active: "+dragItem.Drag.active) //false
                            }
                        }
                    }
                }
            }
        }
    }


    Component.onCompleted: {
        // console.log("rootWindow.visible: "+root.visible)
        // console.log("Component.onCompleted - 6")
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
