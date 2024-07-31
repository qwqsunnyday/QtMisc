import QtQuick 2.15
import QtQuick.Controls 2.15
// import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.15

Rectangle {
    height: 400
    width: 400
    color: "yellow"

    Rectangle {
        anchors.centerIn: parent
        Column {
            Component {
                id: button_with_parameter
                Button {
                    text: "button"
                    property int para: arg
                    onClicked: {
                        console.log("pressed" + "para = " + para + " arg = " + arg)
                    }
                }
            }
            Loader {
                // Load后的Component具备一切Loader所具有的变量上下文
                property int arg: 10
                sourceComponent: button_with_parameter
            }
            Loader {
                // anchors.centerIn: parent
                sourceComponent: Component {
                    Button {
                        text: "qsTr(OK)"
                        onClicked: {
                            console.log("pressed")
                        }
                    }
                }
            }
            Repeater {
                model: 4
            }
        }
    }
}
