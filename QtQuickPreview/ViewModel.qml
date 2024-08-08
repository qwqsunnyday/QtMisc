import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "Utils.js" as Utils


/*
# 文件概述

本文件包括:
    - QML Model的嵌套和引用

*/
Item {
    id: root
    width: 400
    height: 500
    ListModel {
        id: baseModel
        ListElement {
            custom: 1
            custom1: 1
        }
        ListElement {
            custom: 2
            custom1: 2
        }
    }
    ListModel {
        id: nestedModel
    }
    Component {
        id: itemComponent
        Rectangle {
            id: item
            height: 40
            width: 80
            color: "red"
            // 推荐使用required properties而非context properties(qml doc)
            required property int custom
            Text {
                anchors.centerIn: parent
                text: "custom: "+custom
            }
            MouseArea {
                anchors.fill: parent
                onClicked: baseModel.get(0).custom = 1000
            }
        }
    }
    ColumnLayout {
        anchors.fill: parent
        Flow {
            Layout.preferredHeight: parent.height*0.3
            Layout.fillWidth: true
            spacing: 10
            Repeater {
                id: view
                anchors.fill: parent
                model: baseModel
                delegate: itemComponent
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "yellow"

            Flow {
                spacing: 10
                Repeater {
                    model: nestedModel
                    Grid {
                        anchors.fill: parent
                        Repeater {
                            // anchors.fill: parent
                            model: baseModelVar
                            delegate: itemComponent
                        }
                    }
                    Component.onCompleted: {
                        // 相当于一份复制
                        nestedModel.append({"baseModelVar": [baseModel.get(0),baseModel.get(1)]})
                        baseModel.get(0).custom = 999
                        console.log(nestedModel.get(0).baseModelVar.get(0).custom = 114514)
                        console.log(Utils.modelToJSON(baseModel))
                        console.log(Utils.modelToJSON(nestedModel))
                    }
                }
            }
        }
    }


}
