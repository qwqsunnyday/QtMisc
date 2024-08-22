import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    // CustomComponent具有的根属性
    required property var required_para
    // CustomComponent具有的根属性, 是button.para的alias
    property alias para: button.para
    Button {
        id: button
        text: "button1"
        property var para
        onClicked: {
            console.log("para = " + para + " required_para = " + required_para + " context_var: " + context_var);
        }
    }
    Component {
        // Component objects cannot declare new properties.
        id: customComponent
        Button {
            id: button
            text: "button2"
            // 因此Component只能采用基于scope的参数传递
            // required_para: required_para_arg 防止loop binding
            property var required_para: required_para_arg
            property var para: para_arg
            property var context_var: context_var_arg
            onClicked: {
                console.log("para = " + para + " required_para = " + required_para + " context_var: " + context_var);
            }
        }
    }
    Loader {
        anchors.top: button.bottom
        // Load后的Component具备一切Loader所具有的变量上下文
        // 只能基于scope
        property var required_para_arg: "scope: "+2333
        property var para_arg: "scope: "+6666
        property var context_var_arg: "scope: "+114514
        sourceComponent: customComponent
        onLoaded: {
            // 使用item访问Loaded的元素
            // item.required_para = "set by loader.item.required_para: 2333" 不可以, item是加载完毕的
            console.log("Loaded: Accessing item.required_para(Component.Button.required_para):  "+item.required_para)
        }
    }
}
/*
总之, 内联定义的Component无法自定义根参数, 无法使用setSource, 只能依靠共享作用域传递参数
单独文件定义的非常灵活, 直接使用/动态加载都可以

usage:
    1.
    CustomComponent {
        // CustomComponent具有的根属性
        required_para: "2333"
        // CustomComponent具有的根属性, 是button.para的alias
        para: 6666
        // 基于scope
        property var context_var: 114514
        anchors.centerIn: parent
    }

    2.
    Loader {
        id: dynamicComponentLoader
        anchors.centerIn: parent
        // 1. 基于scope
        // property var required_para_arg: "Loader: "+2333
        // property var para_arg: "Loader: "+6666
        property var context_var: "Loader: "+114514
        onLoaded: {
            console.log("Loaded");
        }
    }
    Component.onCompleted: {
        // 2. 使用setSource
        dynamicComponentLoader.setSource("./CustomComponent.qml", {"required_para":"setSource: 123","para":"setSource: 456"});
        console.log("onCompleted");
    }
*/
