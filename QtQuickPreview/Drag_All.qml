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
                keys: ["inSource", "dropped"]
                property var acceptKeys: ["inSource", "dropped"]

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

                    let upItem = drop.source

                    console.log("dropped at: canvasDropArea")
                    console.log(upItem.stringify())
                    if (upItem.stateType !== "inSource") {
                        console.log("not dropped")
                        return
                    }

                    console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")
                    dropModel.append({
                        "uuid": Utils.uuid(),
                        "modelData": upItem.modelData,
                        "posX": drop.x - drop.source.Drag.hotSpot.x,
                        "posY": drop.y - drop.source.Drag.hotSpot.y,
                        "stateType": "dropped",
                        "description": "",
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
                    required property string modelData
                    required property string stateType
                    required property string description
                    required property var info
                    property int sequenceIndex: stateType==="inSequence" ? parent.parent.index : -1

                    function getCurrentData() {
                        return getModel().get(index)
                    }

                    function getModel() {
                        switch (stateType) {
                            case "inSource":
                                return dragModel
                            case "dropped":
                                return dropModel
                            case "inSequence":
                                return sequenceModel.get(sequenceIndex).droppedItemModel
                        }
                    }

                    function stringify() {
                        return Utils._QObjectToJson(getCurrentData())
                    }
                    function actualState() {
                        let str = ""
                        str+="uuid: "+dragItem.uuid+"\n"
                        str+="sequenceIndex: "+dragItem.sequenceIndex+"\n"
                        str+="active: "+dragItem.Drag.active+"\n"
                        str+="type: "+dragItem.Drag.dragType+"\n"
                        str+="state: "+dragItem.stateType+"\n"
                        str+="posX: "+dragItem.posX+" poxY: "+dragItem.posY+"\n"
                        // str+="hotSpot: "+dragItem.Drag.hotSpot.x+" "+dragItem.Drag.hotSpot.y
                        return str
                    }

                    // TODO loop binding
                    // onXChanged: getCurrentData().posX = x
                    // onYChanged: getCurrentData().posY = y

                    x: posX
                    y: posY
                    width: 100
                    height: 100
                    color: "black"
                    objectName: "description of dragItem"

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
                    Drag.mimeData: {"inSource": "inSource", "dropped": "dropped", "inSequence": "inSequence"}
                    // 绑定有风险, 更改时会产生副作用
                    // Drag.keys: ["inSource", "dropped", "inSequence"]
                    // Drag.keys: [stateType]
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
                            // })
                            dragItem.Drag.active = true;
                            // 非常奇怪...因为Drag.start()之后dragItem.Drag.active会设置为true
                            // dragItem.Drag.start()
                            // TODO 注释后会解决无法识别Drop区域的问题, 但是小概率引入无法响应拖拽的问题
                            // dragItem.Drag.startDrag();
                            dragItem.z = 100
                        }
                        onEntered: {
                            // 最终解决办法: hoverEnabled: true然后onEntered中抓取
                            dragItem.grabToImage(function(result) {
                                dragItem.Drag.imageSource = result.url
                                // imageDialog.loadImage(result.url)
                            })
                            // console.log(dragItem.parent == canvas ? "parent == canvas":"0")
                            // console.log("z: "+dragItem.z)
                        }

                        onReleased: {
                            console.log("released");
                            dragItem.Drag.drop();
                            dragItem.z = 0
                            getCurrentData().posX = dragItem.x
                            getCurrentData().posY = dragItem.y
                            // console.log(getCurrentData().posX +" "+ dragItem.x)
                            // console.log(getCurrentData().posY +" "+ dragItem.y)
                        }
                        onClicked: {
                            console.log(dragItem.stringify())
                            // console.log(dragItem.parent==canvas)
                            // console.log(dragItem.Drag.dragType)
                        }
                    }

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

                            // TODO 诡异行为
                            // keys: ["dropped", "inSource"]
                            property var acceptKeys: ["dropped", "inSource"]

                            onEntered: {
                                console.log("entered connectionDropArea")
                            }

                            onDropped: { // connectionArea
                                var upItem = drag.source
                                var downItem = dragItem

                                console.log("dropped at connectionDropArea:")
                                console.log(upItem.stringify())
                                console.log(upItem.stateType)
                                if (!acceptKeys.includes(upItem.stateType)) {
                                    console.log("not dropped")
                                    return
                                }


                                var currentSequenceIndex = downItem.sequenceIndex
                                if(currentSequenceIndex !==-1){
                                    // down已经在一个序列内了
                                    console.log("down已经在一个序列内了")
                                    upItem.getCurrentData().stateType = "inSequence" // in dropModel
                                    // 修改之后不能调用getModel()

                                    // in sequenceModel.get(sequenceIndex).droppedItemModel
                                    downItem.getModel().append(dropModel.get(upItem.index))

                                    dropModel.remove(upItem.index)
                                }else{
                                    // 全新的两个元素
                                    console.log("全新的两个元素")
                                    downItem.getCurrentData().stateType = "inSequence" // in dropModel
                                    upItem.getCurrentData().stateType = "inSequence" // in dropModel
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
                        font.pixelSize: 11
                        text: dragItem.actualState()
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
                                required property int index
                                required property int uuid
                                required property int posX
                                required property int posY
                                // text: Utils._QObjectToJson(dropModel.get(index))
                                text: uuid+" "+posX+" "+posY
                                font.pixelSize: 16
                                Component.onCompleted: {
                                }
                            }
                        }
                        ListView {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            model: sequenceModel
                            delegate: Text {
                                required property int index
                                // text: Utils.modelToJSON(sequenceModel.get(index).droppedItemModel)
                                font.pixelSize: 16
                            }
                        }
                        // Text {
                        //     Layout.fillHeight: true
                        //     Layout.fillWidth: true
                        //     text: {
                        //         Utils.modelToJSON(dropModel)
                        //     }
                        // }
                        // Text {
                        //     Layout.fillHeight: true
                        //     Layout.fillWidth: true
                        //     text: {
                        //         Utils.modelToJSON(sequenceModel)
                        //     }
                        // }
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
                                        "modelData": "data: " + i,
                                        "posX": 0,
                                        "posY": 0,
                                        "stateType": "inSource",
                                        "description": "",
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
                id: removeArea
                anchors.fill: parent

                keys: ["dropped"]
                property var acceptKeys: ["dropped"]

                onEntered: {
                    console.log("entered removeArea")
                }

                onDropped: { // removeArea
                    // dropped(DragEvent drop)
                    // 可以使用drop.source(参数)或drag.source(属性)访问dragItem
                    var upItem = drag.source

                    console.log("dropped at removeArea")
                    console.log(upItem.stringify())
                    if (!acceptKeys.includes(upItem.stateType)) {
                        console.log("not dropped")
                        return
                    }

                    console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")

                    dropModel.remove(upItem.index)
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
