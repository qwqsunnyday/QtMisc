import QtQuick
import QtQuick.Controls

import "DebugUtils.js" as DebugUtils

/*
本QML主要包括:
    回调函数与闭包作用域
    grabToImage时机
    Drag.dragType: Drag.Automatic情况下的平滑拖拽处理
    外部访问Repeater和Loader的元素
    dumpItemTree
    网格叠加层
*/
Window {
    width: 500
    height: 400
    visible: true
    id: rootWindow
    Column {
        id: root
        anchors.fill: parent
        spacing: 10

        Rectangle {
            id: canvas
            height: 0.5*parent.height
            width: parent.width
            color: "yellow"
            z: 1
            ListModel {
                id: dropModel
            }

            Repeater {
                model: dropModel

                delegate: dragCompenent
            }

            DropArea {
                anchors.fill: parent
                // 接受
                keys: ['modelData','text/plain']
                onEntered: {
                    console.log("entered")
                }
                onPositionChanged: {
                    // console.log("pos changed")
                    // console.log(drag.x+" "+drag.y)
                }

                onDropped: {
                    console.log("dropped")
                    console.log(drag.x+" "+drag.y+" "+drag.source.Drag.hotSpot.x+" "+drag.source.Drag.hotSpot.y)
                    if (drop.hasText) {
                        console.log("Drop Keys: " + drop.keys)
                        console.log("Drop Text: " + drop.text)
                    }
                    drag.source.Drag.mimeData["discard"] = "true"
                    console.log(DebugUtils._QObjectToJson( drag.source.Drag.mimeData))
                    dropModel.append({"modelData": drag.source.Drag.mimeData["modelData"], "posX": drop.x - drag.source.Drag.hotSpot.x, "posY": drop.y - drag.source.Drag.hotSpot.y})
                }
                Component.onCompleted: {
                    console.log("rootWindow.visible: "+rootWindow.visible)
                    console.log("Component.onCompleted - 1")
                }
            }
            Component.onCompleted: {
                console.log("rootWindow.visible: "+rootWindow.visible)
                console.log("Component.onCompleted - 2")
            }
        }
        Rectangle {
            id: rectangle
            height: 0.5*parent.height
            width: parent.width
            color: "red"
            z: 0
            Component {
                id: dragCompenent
                Rectangle {
                    id: dragItem
                    x: (typeof(posX)=="undefined") ? 30 : posX
                    y: (typeof(posY)=="undefined") ? 20 : posY
                    width: 100
                    height: 100
                    color: "black"
                    objectName: "description of dragItem"

                    Text {
                        id: txt
                        // anchors.fill: parent
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: parent.width/5
                        text: parent.Drag.mimeData["modelData"]
                    }

                    opacity: Drag.active ? 0.8 : 1

                    // 一般用于跨应用, dragItem可超出窗口范围, 使用mimeData传递数据
                    // 需要自己处理imageSource同时绑定Drag.active: dragArea.drag.active(可选)
                    // 这里为了平滑, 自定义了dragItem.Drag.hotSpot并在pressed时设置Drag.active=true
                    // Drag.active: dragArea.drag.active
                    Drag.dragType: parent == canvas ? Drag.Internal : Drag.Automatic
                    // 默认, 在窗口内进行
                    // Drag.dragType: Drag.Internal
                    Drag.mimeData: {
                        'modelData': "default",
                        'text/plain': "test_string"
                    }
                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        drag.target: dragItem
                        onPressed: {
                            console.log("startDrag")
                            console.log(mouse.x+" "+mouse.y)
                            dragItem.Drag.hotSpot.x = mouse.x
                            dragItem.Drag.hotSpot.y = mouse.y
                            dragItem.Drag.active = true;
                            // dragItem.Drag.startDrag();
                            dragItem.Drag.start()
                        }
                        onReleased: {
                            console.log("released");
                            dragItem.Drag.drop();
                        }
                    }
                    Component.onCompleted: {
                        console.log("rootWindow.visible: "+rootWindow.visible)
                        console.log("Component.onCompleted - 3")
                    }
                }
            }
            Loader {
                id: dragLoader
                sourceComponent: dragCompenent
                onLoaded: {
                    // 此时窗口仍然不可见
                    console.log("rootWindow.visible: "+rootWindow.visible)
                    // 使用item属性访问装载的元素
                    console.log("onLoaded - 1"+ " objectName: "+item.objectName)
                    // 这样会失败
                    // item.grabToImage(function(result) {
                    //     item.Drag.imageSource = result.url
                    //     // dragItem.Drag.active = true
                    // })
                }
            }
            Rectangle {
                color: "#806be7"
                anchors.right: parent.right
                width: parent.width/2
                height: parent.height

                Flow {
                    anchors.fill: parent
                    spacing: 20
                    Repeater {
                        id: dragRepeater
                        model: 2
                        delegate: dragCompenent
                        // 或者
                        // delegate: Component {
                            // ...
                        // }
                        // 但是不能是Loader

                        Component.onCompleted: {
                            console.log("rootWindow.visible: "+rootWindow.visible)
                            console.log("Component.onCompleted - Repeater")
                            // 使用itemAt()获取元素
                            console.log("Accessing property of repeated item using itemAt(): "+itemAt(0).objectName)
                            for (let i = 0; i < count; i++) {
                                itemAt(i).grabToImage(function(result) {
                                    // 注意, 由于是异步, 导致本回调函数可能在for执行完毕后才执行, 此时i已经变成了count
                                    // 如果使用var定义i, 则回调函数始终捕获的是最后的i; 使用let(ES6, 2015)定义块级变量或使用IIFE捕获i可以解决
                                    // 回调函数不会有错误提示
                                    // console.log(i)
                                    itemAt(i).Drag.imageSource = result.url
                                    // imageDialog.loadImage(result.url)
                                })
                            }

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

                            /*
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
                        console.log("rootWindow.visible: "+rootWindow.visible)
                        console.log("Component.onCompleted - Out Repeater")
                        // Repeater外使用itemAt()获取元素
                        console.log("Accessing property of repeated item using itemAt(): "+dragRepeater.itemAt(0).objectName)
                    }
                }
            }
            DropArea {
                anchors.fill: parent
                // keys: ["discard"]
                onDropped: {
                    console.log("dropped")
                    console.log(drag.x+" "+drag.y+" "+drag.source.Drag.hotSpot.x+" "+drag.source.Drag.hotSpot.y)
                    if (drop.hasText) {
                        console.log("Drop Keys: " + drop.keys)
                        console.log("Drop Text: " + drop.text)
                    }
                    console.log(DebugUtils._QObjectToJson( drag.source.Drag.mimeData))

                }
            }

            Component.onCompleted: {
                console.log("rootWindow.visible: "+rootWindow.visible)
                console.log("Component.onCompleted - 4")
                // Loader外使用item属性访问装载的元素
                console.log("Accessing property of repeated item using item: "+dragLoader.item.objectName)
                dragLoader.item.grabToImage(function(result) {
                    dragLoader.item.Drag.imageSource = result.url
                    // imageDialog.loadImage(result.url)
                    // dragItem.Drag.active = true
                })
            }
        }
    }

    Canvas {
        id: gridCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            // // 设置小格的颜色
            // ctx.strokeStyle = "#e0e0e0"; // 浅灰色
            // ctx.lineWidth = 1;
            // // 绘制小格
            // for (var x = 0; x <= width; x++) {
            //     if (x % 10 !== 0) {
            //         ctx.beginPath();
            //         ctx.moveTo(x, 0);
            //         ctx.lineTo(x, height);
            //         ctx.stroke();
            //     }
            // }
            // for (var y = 0; y <= height; y++) {
            //     if (y % 10 !== 0) {
            //         ctx.beginPath();
            //         ctx.moveTo(0, y);
            //         ctx.lineTo(width, y);
            //         ctx.stroke();
            //     }
            // }

            // 设置大格的颜色
            ctx.strokeStyle = "#808080"; // 灰色
            ctx.lineWidth = 1;
            // 绘制大格
            for (var x = 0; x <= width; x += 10) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, height);
                ctx.stroke();
            }
            for (var y = 0; y <= height; y += 10) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }
        }
        onWidthChanged: gridCanvas.requestPaint()
        onHeightChanged: gridCanvas.requestPaint()
        Component.onCompleted: {
            console.log("rootWindow.visible: "+rootWindow.visible)
            console.log("Component.onCompleted - 5")
        }
    }
    Component.onCompleted: {
        console.log("rootWindow.visible: "+rootWindow.visible)
        console.log("Component.onCompleted - 6")
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
        targetWindow: rootWindow
    }
}
