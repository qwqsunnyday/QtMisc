import QtQuick

Item {
    width: 200; height: 200

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("CustomComponent.qml Loading")
            // 在**运行**时响应更改, http url同理
            let pathUrl="./CustomComponent.qml"+"#"+ new Date().getTime()
            dynamicComponentLoader.setSource(pathUrl, {"required_para":"setSource: 123","para":"setSource: 456"});
            // 2. 使用setSource
            // dynamicComponentLoader.setSource(pathUrl, {"required_para":"setSource: 123","para":"setSource: 456"})
        }
    }
    Loader {
        id: dynamicComponentLoader
        height: 50
        width: 60
        anchors.centerIn: parent
        // 1. 基于scope
        // property var required_para_arg: "Loader: "+2333
        // property var para_arg: "Loader: "+6666
        property var context_var: "Loader: "+114514
        onLoaded: {
            // 3. 使用item访问Loaded的元素
            console.log("dynamicComponentLoader Loaded: Accessing item.required_para:  "+item.required_para);
        }
        // 4. 直接通过嵌套Component方式初始化sourceComponent
        // sourceComponent: Component {
        //     CustomComponent {
        //         required_para: "Component wrapper: 2333"
        //         para: "Component wrapper: 6666"
        //     }
        // }
    }
    Component.onCompleted: {
        // 2. 使用setSource
        dynamicComponentLoader.setSource("./CustomComponent.qml#0", {"required_para":"setSource: 123","para":"setSource: 456"});
        console.log("onCompleted");
    }

    // CustomComponent {
    //     // CustomComponent具有的根属性
    //     required_para: "2333"
    //     // CustomComponent具有的根属性, 是button.para的alias
    //     para: 6666
    //     // 基于scope
    //     property int context_var: 114514
    //     anchors.centerIn: parent
    // }
}
