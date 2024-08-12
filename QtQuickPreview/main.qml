import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import QtCore

import "Utils.js" as Utils

import io.emulator 1.0

Item {
    id: root

    anchors.fill: parent
    anchors.margins: 1

    Settings {
        id: settings
        property bool debug: debugSwitch.checked
        property color highLightColor: debug ? Qt.lighter("red") : "transparent"
    }

    RowLayout {
        anchors.fill: parent

        Rectangle {
            id: leftZone

            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: Qt.lighter("gray")
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4

                Rectangle {
                    id: canvas
                    clip: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: Qt.lighter("gray")
                    border.width: 2

                    z: 1

                    // MVC

                    ListModel {
                        id: sourceModel
                        ListElement { name: "9XUAS"; internalName: "9XUAS"; type: "启动子"; fillColor: "orange"; description: "" }
                        ListElement { name: "CMV"; internalName: "CMV"; type: "启动子"; fillColor: "orange"; description: "" }
                        ListElement { name: "U6_P"; internalName: "U6_P"; type: "启动子"; fillColor: "orange"; description: "" }
                        ListElement { name: "GAL4"; internalName: "GAL4"; type: "蛋白质编码区"; fillColor: "orange"; description: "" }
                        ListElement { name: "INS"; internalName: "INS"; type: "蛋白质编码区"; fillColor: "orange"; description: "" }
                        ListElement { name: "Luciferase"; internalName: "Luciferase"; type: "蛋白质编码区"; fillColor: "orange"; description: "" }
                        ListElement { name: "miRNA"; internalName: "miRNA"; type: "蛋白质编码区"; fillColor: "orange"; description: "" }
                        ListElement { name: "P_GIP"; internalName: "P_GIP"; type: "蛋白质编码区"; fillColor: "orange"; description: "" }
                        ListElement { name: "miRNA_BS"; internalName: "miRNA_BS"; type: "蛋白质编码区"; fillColor: "orange"; description: "" }
                        ListElement { name: "LOV"; internalName: "LOV"; type: "蛋白质编码区"; fillColor: "orange"; description: "" }
                        ListElement { name: "VP16"; internalName: "VP16"; type: "蛋白质编码区"; fillColor: "orange"; description: "" }
                    }

                    ListModel {
                        id: dragModel
                        // ListElement {
                        //     uuid: int
                        //     modelData: string
                        //     posX: real
                        //     posY: real
                        //     itemWidth: real
                        //     itemHeight: real
                        //     stateType: string ["inSource" | "dropped" | "inSequence"]
                        //     sourceData: var
                        // }
                    }

                    ListModel {
                        id: dropModel
                        // ListElement 本身也是ListModel
                        // 使用Object承载数据时, Model只读, 无法修改
                        // Model和View是单向绑定(MVC)
                        // sequenceIndex 可以通过parent.parent.index访问(当stateType=="inSequence")
                        // ListElement {
                        //     uuid: int
                        //     modelData: string
                        //     posX: real
                        //     posY: real
                        //     itemWidth: real
                        //     itemHeight: real
                        //     stateType: string ["inSource" | "dropped" | "inSequence"]
                        //     sourceData: var
                        // }
                    }

                    ListModel {
                        id: sequenceModel
                        // ListElement {
                        //     uuid: int
                        //     droppedItemModel: var
                        //     posX: real
                        //     posY: real
                        // }
                    }

                    Repeater {
                        id: sequenceRepeater
                        model: sequenceModel

                        delegate: sequenceComponent
                    }

                    Repeater {
                        id: dropRepeater
                        model: dropModel

                        delegate: dragCompenent
                    }

                    Component {
                        id: sequenceComponent

                        Rectangle {
                            id: sequenceItem
                            color: "transparent"
                            border.color: settings.highLightColor
                            border.width: 4
                            z: 10

                            required property var droppedItemModel
                            required property int uuid
                            required property int index
                            required property real posX
                            required property real posY

                            height: calHeight()
                            width: calWidth()
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

                            function calHeight() {
                                let childrenHeight = 0.0
                                for (let i = 0; i < droppedItemModel.count ; i++) {
                                    childrenHeight = Math.max(childrenHeight, droppedItemModel.get(i).itemHeight)
                                }
                                return childrenHeight
                            }

                            function calWidth() {
                                let childrenWidth = 0.0
                                for (let i = 0; i < droppedItemModel.count ; i++) {
                                    childrenWidth += droppedItemModel.get(i).itemWidth
                                }
                                return childrenWidth
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

                            Rectangle {
                                width: parent.width
                                height: 48
                                anchors.bottom: parent.bottom

                                color: "transparent"
                                border.color: settings.highLightColor
                                border.width: 4

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
                                        sequenceItem.z-=1
                                        console.log("sequenceItem released")
                                        sequenceItem.Drag.drop()
                                        sequenceItem.getCurrentData().posX = sequenceItem.x
                                        sequenceItem.getCurrentData().posY = sequenceItem.y
                                    }
                                    onDoubleClicked: {
                                        console.log("sequenceItem doubleClicked")

                                        for (let i = 0; i < droppedItemModel.count ; i++) {
                                            // 修改状态后重新加入
                                            let reAddItem = droppedItemModel.get(i)
                                            reAddItem.stateType = "dropped"
                                            reAddItem.posX = sequenceItem.posX + i * (reAddItem.itemWidth + 15)
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
                    }

                    Component {
                        id: dragCompenent

                        Rectangle {
                            id: dragItem

                            // 要手动加才可以访问index附加属性
                            required property int index
                            required property int uuid
                            required property real posX
                            required property real posY
                            required property real itemWidth
                            required property real itemHeight
                            required property string modelData
                            required property string stateType
                            required property var sourceData

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
                            width: itemWidth
                            height: itemHeight
                            color: "transparent"
                            border.color: settings.highLightColor
                            border.width: 2
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

                            Repeater {
                                model: dragItem.sourceData
                                delegate: GeneticElementComponent {
                                    height: dragItem.itemHeight
                                    width: dragItem.itemWidth
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 48
                                anchors.bottom: parent.bottom

                                color: "transparent"
                                border.color: settings.highLightColor
                                border.width: 4
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
                                        // mouse.x+" "+mouse.y是相对于当前item(dragArea)的
                                        // console.log(mouse.x+" "+mouse.y)
                                        dragItem.Drag.hotSpot.x = mapToItem(dragItem, Qt.point(mouse.x, mouse.y)).x
                                        dragItem.Drag.hotSpot.y = mapToItem(dragItem, Qt.point(mouse.x, mouse.y)).y
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
                            }

                            RowLayout {
                                anchors.fill: parent
                                Repeater {
                                    model: 2

                                    delegate: Rectangle {
                                        id: connectionArea
                                        color: "transparent"
                                        border.color: settings.highLightColor
                                        border.width: 2
                                        // anchors.fill: parent
                                        // anchors.margins: 4
                                        Layout.preferredHeight: 45
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignBottom

                                        // 区分左右连接区域
                                        required property int index

                                        DropArea {
                                            id: connectionDropArea
                                            anchors.fill: parent

                                            keys: ["dropped", "inSource"]

                                            function checkCompatibility(upItem, downItem) {
                                                if (!keys.includes(upItem.stateType)) {
                                                    return false
                                                }
                                                if (upItem.sourceData.type==="启动子") {
                                                    return false
                                                }
                                                if (downItem.sourceData.type==="启动子" && connectionArea.index===0) {
                                                    return false
                                                }
                                                return true
                                            }

                                            Connections {
                                                target: connectionDropArea
                                                function onEntered (mouse) {
                                                    dragItemOpacityAnimation.start()
                                                }
                                                function onExited (mouse) {
                                                    dragItemOpacityAnimationReversed.start()
                                                }
                                            }

                                            onEntered: {
                                                // console.log("entered connectionDropArea, index: "+connectionArea.index)
                                            }

                                            onDropped: { // connectionArea
                                                var upItem = drag.source
                                                var downItem = dragItem

                                                console.log("dropped at connectionDropArea:")
                                                // 需要针对不同的组件类型进行过滤
                                                if (!checkCompatibility(upItem, downItem)) {
                                                    console.log("not dropped")
                                                    return
                                                }
                                                console.log(upItem.stringify())
                                                if (upItem.stateType === "inSource") {
                                                    dropModel.append({
                                                        "uuid": Utils.uuid(),
                                                        "modelData": upItem.modelData,
                                                        "posX": drop.x - drop.source.Drag.hotSpot.x,
                                                        "posY": drop.y - drop.source.Drag.hotSpot.y,
                                                        "stateType": "inSequence",
                                                        "sourceData": upItem.sourceData,
                                                        "itemWidth": upItem.itemWidth,
                                                        "itemHeight": upItem.itemHeight
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

                                                    // 左区域则插在前面, 否则插在后面
                                                    // in sequenceModel.get(sequenceIndex).droppedItemModel
                                                    console.log(downItem.index+" "+connectionArea.index)
                                                    downItem.getModel().insert(downItem.index + connectionArea.index, dropModel.get(upItemIndex))

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
                                }
                            }

                            Text {
                                id: txt
                                visible: settings.debug
                                anchors.centerIn: parent
                                color: "gray"
                                font.pixelSize: 11
                                text: dragItem.actualState()
                            }
                        }
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
                                "stateType": "dropped",
                                "sourceData": upItem.sourceData,
                                "itemWidth": upItem.itemWidth,
                                "itemHeight": upItem.itemHeight
                            })

                            if (upItem.pressed) {
                                // workaround... >_<###
                                dragRepeater.rePresent()
                            }
                        }
                    }
                }
                Rectangle {
                    id: source
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: Qt.lighter("gray")
                    border.width: 2
                    z: 0

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 10
                        border.color: Qt.lighter("gray")
                        border.width: 2
                        // ScrollView需要指定Flow的宽高: 宽高达到一定程度才会Scroll
                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            anchors.margins: 4
                            Flow {
                                width: source.width
                                height: source.width
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
                                        for (let i = 0; i < sourceModel.count; i++) {
                                            dragModel.append({
                                                "uuid": i+1,
                                                "modelData": "data: " + i,
                                                "posX": 0,
                                                "posY": 0,
                                                "stateType": "inSource",
                                                "sourceData": sourceModel.get(i),
                                                "itemWidth": 200,
                                                "itemHeight": 100
                                            })
                                        }
                                    }

                                    Component.onCompleted: {
                                        for (let i = 0; i < sourceModel.count; i++) {
                                            Utils.uuid()
                                        }
                                        rePresent()
                                    }
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
                }
            }

        }
        Rectangle {
            id: rightZone

            Layout.fillHeight: true
            Layout.preferredWidth: bar.implicitWidth+80
            border.color: Qt.lighter("gray")
            border.width: 2
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                Rectangle {
                    id: interactiveZone
                    Layout.minimumHeight: 240
                    Layout.fillWidth: true
                    border.color: Qt.lighter("gray")
                    border.width: 2

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        anchors.margins: 20

                        Rectangle {
                            Layout.preferredHeight: 100
                            Layout.fillWidth: true
                            border.color: Qt.lighter("gray")
                            border.width: 2
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
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                        }

                        // 为了使用居中
                        RowLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
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
                    id: functionZone
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: Qt.lighter("gray")
                    border.width: 2

                    MouseArea {
                        anchors.fill: parent
                        // 定义一个计时器来聚合滚动事件
                        Timer {
                            id: scrollTimer
                            interval: 100 // 设置合适的时间间隔（毫秒）
                            repeat: false
                        }

                        onWheel: {
                            // 响应一次滚动:
                            // 1. 当滚轮事件开始且计时器没有运行
                            // 2. 方向切换了
                            if(wheel.inverted||(!scrollTimer.running)||((Math.abs(wheel.angleDelta.y)>=120)||(Math.abs(wheel.angleDelta.y)>=120))){
                                scrollTimer.start();
                                if(wheel.angleDelta.x<0||wheel.angleDelta.y<0){
                                    // index遵循C风格
                                    if(bar.currentIndex===bar.count-1){
                                        bar.setCurrentIndex(0)
                                    }else{
                                        bar.incrementCurrentIndex();
                                    }
                                }else{
                                    if(bar.currentIndex===0){
                                        bar.setCurrentIndex(bar.count-1)
                                    }else{
                                        bar.decrementCurrentIndex();
                                    }
                                }
                            }else{
                                scrollTimer.restart();
                            }
                           // console.log(wheel.angleDelta);
                        }
                    }
                    // SwipeView无法直接获取事件响应, 因此将MouseArea放在SwipeView的下面

                    ColumnLayout {
                        anchors.fill: parent
                        // 注意: 将TabBar放在SwipeView之上防止接受不到鼠标输入
                        Rectangle {
                            Layout.preferredHeight: bar.implicitHeight
                            Layout.fillWidth: true
                            border.color: Qt.lighter("gray")
                            border.width: 2
                            TabBar {
                                id: bar
                                anchors.fill: parent
                                anchors.margins: 2

                                // 双向绑定
                                currentIndex: view.currentIndex

                                Repeater {
                                    model: ["Tutorial", "Protein", "Questions", "Load"]
                                    delegate:                                     TabButton {
                                        text: modelData
                                        background:
                                          Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            border.color: Qt.lighter("gray")
                                            border.width: 2
                                        }
                                    }
                                }
                            }
                        }

                        SwipeView {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            id: view
                            // 双向绑定
                            currentIndex: bar.currentIndex

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
                                ColumnLayout {
                                    anchors.fill: parent
                                    Rectangle {
                                        height: bar.implicitHeight
                                        width: bar.implicitWidth
                                        color: "transparent"
                                    }

                                    RowLayout {
                                        id: controlPanel
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 28
                                        Layout.alignment: Qt.AlignCenter | Qt.AlignTop
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
                                        Button {
                                            id: debugSwitch
                                            text: "Debug"
                                            checkable: true
                                        }
                                        Button {
                                            id: evaluate
                                            text: "Evaluate"
                                            onClicked: {
                                                console.log(emulator.evaluate(Utils.modelToJSON(sequenceModel)))
                                            }
                                            Emulator {
                                                id: emulator
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
                                }

                                Text {
                                    text: "load"
                                    anchors.centerIn: parent
                                }
                            }
                        }
                        PageIndicator {
                            id: indicator

                            count: view.count
                            currentIndex: view.currentIndex

                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                }
            }
        }
    }
}
