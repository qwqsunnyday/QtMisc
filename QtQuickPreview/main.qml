import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal

import "Utils.js" as Utils

Item {
    width: 500
    height: 400
    visible: true
    id: root


    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            id: controlPanel
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            Button {
                id: clear
                text: "Clear"
                onClicked: {
                    dropModel.clear()
                    sequenceModel.clear()
                }
            }
            Button {
                id: restore
                text: "Restore"
                onClicked: {
                    // save.data为对象数组
                    dropModel.append(save.dropModelData)
                    sequenceModel.append(save.sequenceModelData)
                }
            }
            Button {
                id: save
                text: "Save"
                property var dropModelData
                property var sequenceModelData
                onClicked: {
                    dropModelData = JSON.parse(Utils.modelToJSON(dropModel))
                    sequenceModelData = JSON.parse(Utils.modelToJSON(sequenceModel))
                }
            }
            JSConsoleButton {
                windowHeight: 600
                windowWidth: 800
                predefinedCommands: [
                    "Utils.getRepeaterItem(dragRepeater, 1)",
                    "Utils.getRepeaterItem(dropRepeater, 4)",
                    "Utils.modelToJSON(dragModel)",
                    "Utils.modelToJSON(dropModel)",
                    "Utils.modelToJSON(sequenceModel)"
                ]
            }
        }

        Rectangle {
            id: canvas
            clip: true
            Layout.preferredHeight: 0.5* parent.height
            Layout.fillWidth: true
            color: "yellow"
            z: 1
            ListModel {
                id: dropModel
                // 由于对象可能随意实例化, 因此持久化信息必须保存在model中!!!
                // ListElement 本身也是ListModel
                // 使用Object承载数据时, 是副本, 无法修改
                // Model和View是单项绑定, view无法影响Model
                // ListModel等可以进行绑定, 否则需要自行在C++/Python实现
                // sequenceIndex 可以通过parent.parent.index访问(当stateType=="inSequence")
                // ListElement {
                //     uuid: 0
                //     modelData: ""
                //     posX: 0
                //     posY: 0
                //     stateType: "" inSource dropped inSequence
                // }
            }

            ListModel {
                id: sequenceModel
                // ListElement {
                //     uuid: 0
                //     droppedItemModel: undefined
                //     posX: 0
                //     posY: 0
                // }
            }

            Repeater {
                model: sequenceModel


                delegate: Rectangle {
                    id: sequenceItem
                    color: "pink"
                    z: 10

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

                    function getCurrentData() {
                        return sequenceModel.get(index)
                    }

                    function stringify() {
                        let str = ""
                        str+="uuid: "+sequenceItem.uuid+"\n"
                        str+="posX: "+sequenceItem.posX+" posY: "+sequenceItem.posY+"\n"
                        str+=Utils.modelToJSON(droppedItemModel)
                        return str
                    }

                    property string stateType: "isSequence"

                    Drag.dragType: Drag.Internal
                    Drag.keys: [stateType]

                    MouseArea {
                        anchors.fill: parent
                        drag.target: sequenceItem

                        onPressed: {
                            canvas.clip = false
                            sequenceItem.z+=1
                            console.log("sequenceItem started")
                            sequenceItem.Drag.start()
                        }
                        onReleased: {
                            canvas.clip = true
                            sequenceItem.z -=1
                            console.log("sequenceItem released")
                            sequenceItem.Drag.drop()
                            sequenceItem.getCurrentData().posX = sequenceItem.x
                            sequenceItem.getCurrentData().posY = sequenceItem.y
                        }
                        onDoubleClicked: {
                            console.log("sequenceItem doubleClicked")

                            for (let i = 0; i < droppedItemModel.count ; i++) {
                                let reAddItem = droppedItemModel.get(i)
                                reAddItem.stateType = "dropped"
                                reAddItem.posX = sequenceItem.posX + i*110
                                reAddItem.posY = sequenceItem.posY
                                dropModel.append(reAddItem)
                            }
                            sequenceModel.remove(index)
                        }
                        onClicked: {
                            console.log(sequenceItem.stringify())
                        }
                    }
                }
            }
            Repeater {
                id: dropRepeater
                model: dropModel

                delegate: dragCompenent
            }

            DropArea {
                id: canvasDropArea
                anchors.fill: parent
                // 接受
                keys: ["inSource", "dropped"]

                onEntered: {
                    // console.log("entered canvasDropArea")
                }
                // DropArea还具有drag.source属性
                onDropped: { // canvasDropArea
                    // dropped(DragEvent drop)
                    // 可以使用drop.source(参数)或drag.source(属性)访问dragItem
                    let upItem = drop.source

                    console.log("dropped at: canvasDropArea")
                    // console.log(upItem.stringify())
                    if (upItem.stateType !== "inSource") {
                        console.log("not dropped")
                        return
                    }

                    // console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")
                    dropModel.append({
                        "uuid": Utils.uuid(),
                        "modelData": upItem.modelData,
                        "posX": drop.x - drop.source.Drag.hotSpot.x,
                        "posY": drop.y - drop.source.Drag.hotSpot.y,
                        "stateType": "dropped"
                    })
                    if (upItem.pressed) {
                        // workaround... >_<###
                        dragRepeater.rePresent()
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
                    // 绑定容易出问题
                    property int sequenceIndex: (stateType==="inSequence" && (typeof(parent.parent.index)!="undefined")) ? parent.parent.index : -1

                    function getSequenceIndex() {
                        if (stateType==="inSequence") {
                            if ((typeof(parent.parent.index)=="undefined")){
                                return -1
                            }
                            return parent.parent.index
                        }
                    }

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
                        // str+="sequenceIndex: "+dragItem.sequenceIndex+"\n"
                        str+="z: "+dragItem.z+"\n"
                        str+="active: "+dragItem.Drag.active+"\n"
                        str+="pressed: "+pressed+"\n"
                        str+="type: "+(dragItem.Drag.dragType == Drag.Internal ? "Internal" : "Automatic")+"\n"
                        str+="state: "+dragItem.stateType+"\n"
                        str+="posX: "+dragItem.posX+" posY: "+dragItem.posY+"\n"
                        // str+="hotSpot: "+dragItem.Drag.hotSpot.x+" "+dragItem.Drag.hotSpot.y
                        return str
                    }

                    // TODO loop binding
                    // onXChanged: getCurrentData().posX = x
                    // onYChanged: getCurrentData().posY = y

                    x: posX
                    y: posY
                    // 这里z值非常重要, 至少要比canvasArea高
                    z: 10
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
                    // Drag.dragType: parent == canvas ? Drag.Internal : Drag.Automatic
                    Drag.dragType: (stateType === "dropped" || stateType === "inSequence") ? Drag.Internal : Drag.Automatic
                    // 默认, 在窗口内进行
                    // Drag.dragType: Drag.Internal
                    Drag.mimeData: {"inSource": "inSource", "dropped": "dropped", "inSequence": "inSequence"}
                    Drag.keys: [stateType]

                    property alias pressed: dragArea.pressed
                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        drag.target: dragItem
                        hoverEnabled: true
                        preventStealing: true
                        onPressed: {
                            canvas.clip = false
                            dragItem.z +=1
                            console.log("startDrag")
                            // console.log(mouse.x+" "+mouse.y)
                            dragItem.Drag.hotSpot.x = mouse.x
                            dragItem.Drag.hotSpot.y = mouse.y
                            // 问题在于, 由于是异步调用, 点击时不会立即生成图像, 第二次点击才可
                            // dragItem.grabToImage(function(result) {
                            //     dragItem.Drag.imageSource = result.url
                            // })
                            if (dragItem.Drag.dragType === Drag.Internal){
                                dragItem.Drag.start()
                            } else {
                                dragItem.Drag.active = true
                            }
                        }
                        onEntered: {
                            // 最终解决办法: hoverEnabled: true然后onEntered中抓取
                            if (dragItem.Drag.dragType === Drag.Automatic){
                                dragItem.grabToImage(function(result) {
                                    dragItem.Drag.imageSource = result.url
                                    // imageDialog.loadImage(result.url)
                                })
                            }
                        }
                        // onPressedChanged: {
                        //     问题在于, drop后pressed依然为true
                        //     if (dragArea.pressed) {
                        //     }else {
                        //     }
                        // }

                        onReleased: {
                            canvas.clip = true
                            // 大问题, onReleased()有一定几率凭空不会被调用
                            dragItem.z -=1
                            console.log("onReleased");
                            dragItem.Drag.drop();
                            getCurrentData().posX = dragItem.x
                            getCurrentData().posY = dragItem.y
                        }
                        onClicked: {
                            console.log("onClicked")
                        }
                        // onPressAndHold: {
                        //     console.log("onPressAndHold")
                        //     console.log(dragItem.stringify())
                        // }
                        onCanceled: {
                            console.error("onCanceled !")
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

                            // keys: ["dropped"]
                            keys: ["dropped", "inSource"]

                            onEntered: {
                                // console.log("entered connectionDropArea")
                            }

                            onDropped: { // connectionArea
                                var upItem = drag.source
                                var downItem = dragItem

                                console.log("dropped at connectionDropArea:")
                                console.log(upItem.stringify())
                                console.log(upItem.stateType)
                                if (!keys.includes(upItem.stateType)) {
                                    console.log("not dropped")
                                    return
                                }
                                if (upItem.stateType === "inSource") {
                                    dropModel.append({
                                        "uuid": Utils.uuid(),
                                        "modelData": upItem.modelData,
                                        "posX": drop.x - drop.source.Drag.hotSpot.x,
                                        "posY": drop.y - drop.source.Drag.hotSpot.y,
                                        "stateType": "inSequence"
                                    })
                                }
                                let upItemIndex = upItem.stateType === "inSource" ? dropModel.count-1 : upItem.index

                                if (upItem.stateType === "dropped") {
                                    upItem.getCurrentData().stateType = "inSequence" // in dropModel
                                }
                                let currentSequenceIndex = downItem.sequenceIndex
                                if(currentSequenceIndex !==-1){
                                    // down已经在一个序列内了
                                    console.log("down已经在一个序列内了")
                                    // 修改之后不能调用getModel()

                                    // in sequenceModel.get(sequenceIndex).droppedItemModel
                                    downItem.getModel().insert(downItem.index+1, dropModel.get(upItemIndex))

                                    if (upItem.pressed) {
                                        // workaround... >_<###
                                        dragRepeater.rePresent()
                                    }

                                    dropModel.remove(upItemIndex)
                                }else{
                                    // 全新的两个元素
                                    console.log("全新的两个元素")
                                    downItem.getCurrentData().stateType = "inSequence" // in dropModel
                                    sequenceModel.append({
                                        uuid: Utils.uuid(),
                                        droppedItemModel: [dropModel.get(downItem.index), dropModel.get(upItemIndex)],
                                        posX: dragItem.x,
                                        posY: dragItem.y
                                    })
                                    if (upItem.pressed) {
                                        // workaround... >_<###
                                        dragRepeater.rePresent()
                                    }
                                    dropModel.remove(upItemIndex)
                                    dropModel.remove(downItem.index)
                                }

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
                                text: Utils.modelToJSON(sequenceModel.get(index).droppedItemModel)
                                font.pixelSize: 16
                            }
                        }
                    }
                }

                Rectangle {
                    color: "#806be7"
                    Layout.fillHeight: true
                    Layout.preferredWidth: 0.3* parent.width

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

                            function rePresent() {
                                canvas.clip = true
                                dragModel.clear()
                                for (let i = 0; i < 3; i++) {
                                    dragModel.append({
                                        "uuid": i+1,
                                        "modelData": "data: " + i,
                                        "posX": 0,
                                        "posY": 0,
                                        "stateType": "inSource"
                                    })
                                }
                            }

                            Component.onCompleted: {
                                for (let i = 0; i < 3; i++) {
                                    dragModel.append({
                                        "uuid": Utils.uuid(),
                                        "modelData": "data: " + i,
                                        "posX": 0,
                                        "posY": 0,
                                        "stateType": "inSource"
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
                            // Repeater外使用itemAt()获取元素
                            // console.log("Accessing property of repeated item using itemAt(): "+dragRepeater.itemAt(0).objectName)
                        }
                    }
                }
            }

            DropArea {
                id: removeArea
                anchors.fill: parent

                keys: ["dropped", "isSequence"]

                onEntered: {
                    // console.log("entered removeArea")
                }

                onDropped: { // removeArea
                    // dropped(DragEvent drop)
                    // 可以使用drop.source(参数)或drag.source(属性)访问dragItem
                    var upItem = drag.source

                    console.log("dropped at removeArea")
                    console.log(upItem.stringify())
                    if (!keys.includes(upItem.stateType)) {
                        console.log("not dropped")
                        return
                    }
                    // console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")
                    switch (upItem.stateType ) {
                        case "isSequence":
                            sequenceModel.remove(upItem.index)
                            break
                        case "dropped":
                            dropModel.remove(upItem.index)
                            break
                    }

                    if (upItem.pressed) {
                        // workaround... >_<###
                        dragRepeater.rePresent()
                    }
                }
            }

            Component.onCompleted: {
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

