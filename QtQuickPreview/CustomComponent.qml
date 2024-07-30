import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    // CustomComponent具有的根属性
    required property var required_para
    // CustomComponent具有的根属性, 是button.para的alias
    property alias para: button.para
    Button {
        id: button
        text: "button"
        property int para
        onClicked: {
            console.log("para = " + para + " required_para = " + required_para + " context_var: " + context_var);
        }
    }
    Component {
        // Component objects cannot declare new properties.
        id: customComponent
        Button {
            id: button
            text: "button"
            // 因此Component只能采用基于scope的参数传递
            property var required_para: required_para_arg
            property int para: para_arg
            property int context_var: context_var_arg
            onClicked: {
                console.log("para = " + para + " required_para = " + required_para + " context_var: " + context_var);
            }
        }
    }
    Loader {
        anchors.top: button.bottom
        // Load后的Component具备一切Loader所具有的变量上下文
        // 基于scope
        property var required_para_arg: "2333"
        property int para_arg: 6666
        property int context_var_arg: 114514
        sourceComponent: customComponent
    }
}
/*
usage:
    CustomComponent {
        // CustomComponent具有的根属性
        required_para: "2333"
        // CustomComponent具有的根属性, 是button.para的alias
        para: 6666
        // 基于scope
        property int context_var: 114514
        anchors.centerIn: parent
    }

*/
