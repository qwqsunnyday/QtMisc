import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal

import "Utils.js" as Utils


/*
# 文件概述

本文件包括:
    - QML View Model
        Model -> View 单向绑定
        QML原生不是MVVM的
    - QML Model的嵌套和引用
    - QML Model内存储JS Object

*/
Item {
    id: root
    width: 400
    height: 500

    property var provider: Utils.dataProvider()
    Binding {

    }

    ListModel {
        id: baseModel
        // customVar为Object
    }
    // ListModel {
    //     // // 不可用
    //     id: baseModelv2
    //     // customVar为ListElement(ListModel)
    //     ListElement {
    //         custom: -1
    //         customVar: ListElement {
    //             property1: -2
    //             property2: -3
    //         }
    //     }
    // }
    ListModel {
        id: uuidModel
    }
    ListModel {
        id: nestedModel
    }
    Component {
        id: itemComponent
        Rectangle {
            id: item
            height: 40
            width: 200
            color: "red"
            // 推荐使用required properties而非context properties(qml doc)
            required property int index
            required property int custom
            required property var customVar
            Text {
                anchors.centerIn: parent
                text: "customVar.property1: "+customVar.property1+"\n"+"custom:"+custom
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    custom = 9999999
                    console.log("custom:"+custom)
                    // Model -> View的单向绑定, 更改只作用于View
                    console.log("baseModel.get(index).custom: "+baseModel.get(index).custom)
                    baseModel.get(0).custom = 1000
                    baseModel.get(0).customVar.property1 = 114514
                }
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
                        baseModel.append({custom:1, customVar: {property1: 2, property2: 3}})
                        baseModel.append({custom:4, customVar: {property1: 5, property2: 6}})
                        console.log(baseModel.get(0).custom)
                        console.log(baseModel.get(0).customVar) // Object
                        console.log(baseModel.get(0)["customVar"]) // Object
                        // 相当于一份复制
                        nestedModel.append({"baseModelVar": [baseModel.get(0),baseModel.get(1)]})
                        baseModel.get(0).custom = 999
                        nestedModel.get(0).baseModelVar.get(0).custom = 114514
                        nestedModel.get(0).baseModelVar.get(0).customVar.property1 = 666
                        console.log(Utils.modelToJSON(baseModel))
                        console.log(Utils.modelToJSON(nestedModel))
                        console.log(Utils._QObjectToJson(baseModel.get(1)))

                        return
                        // 不可用
                        console.log("baseModelv2:")
                        var tmp = Qt.createQmlObject("import QtQuick;ListModel {ListElement{property1: 2; property2: 3}}", baseModelv2)
                        // baseModelv2.append({custom:1, customVar: tmp})
                        baseModelv2.append({custom:1, customVar: []})
                        baseModelv2.setProperty(0, "customVar", tmp)
                        console.log(tmp) // // QQmlListModel
                        console.log(baseModelv2.get(0).customVar) // QQmlListModel
                        console.log(Utils.modelToJSON(baseModelv2.get(0).customVar))
                        console.log(Utils.modelToJSON(tmp))
                        console.log(tmp.get(0))
                        console.log(Utils.modelToJSON(baseModelv2))
                    }
                }
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "green"

            Flow {
                spacing: 10
                Repeater {
                    model: uuidModel
                    delegate:  Rectangle {
                        id: item
                        height: 40
                        width: 200
                        color: "gray"
                        Text {
                            id: txt
                            anchors.centerIn: parent
                            // 无法绑定至纯JS函数!!! 仅能获取静态值
                            text: root.provider.toJSON(uuid)
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log(uuid)
                                console.log(root.provider.toJSON())
                                console.log(JSON.stringify(root.provider.get(uuid)))
                                root.provider.get(uuid).age = "1000"
                                // txt.textChanged()
                                console.log(JSON.stringify(root.provider.get(uuid)))
                            }
                        }

                        Component.onCompleted: {
                            // 无法绑定至纯JS函数!!! 仅能获取静态值
                            // 只有QObject才可以
                            txt.text = Qt.binding(function(){return root.provider.toJSON(uuid)})
                        }
                    }
                    Component.onCompleted: {
                        uuidModel.append({uuid: provider.append({ name: "Bobby Ling", age: 20 })})
                    }
                }
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "pink"

            RowLayout {
                anchors.fill: parent
                Slider {
                    id: slider1
                    from: 100
                    to: 1000
                    // #1
                    // value: slider2.value
                }
                Slider {
                    id: slider2
                    from: 100
                    to: 1000
                    // 默认是slider1.value -> value的单向绑定
                    value: slider1.value
                    // #2 与#1等效
                    // Binding {
                    //     target:
                    //     这里property使用字符串是为了便于访问
                    //     property: "value"
                    //     value: slider2.value
                    // }
                    // #3 与#2等效
                    Binding {
                        slider1.value: slider2.value
                    }
                }
            }

        }
    }
    Component.onCompleted: {
        const uuid1 = provider.append({ name: "Alice", age: 30 });
        const uuid2 = provider.append({ name: "Bob", age: 25 });

        console.log("All data:");
        console.log(provider.toString());

        console.log("Get by UUID:");
        console.log(JSON.stringify(provider.get(uuid1)));
        console.log(provider.toJSON(uuid1));

        console.log("Remove by UUID:");
        console.log(provider.remove(uuid2));

        console.log("Data after removal:");
        console.log(provider.toString());

        console.log("Data in JSON format:");
        console.log(provider.toJSON());
    }

}
