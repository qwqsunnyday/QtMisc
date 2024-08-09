import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal

Button {
    Window {
        id: jsConsole
        width: 400
        height: 500
        JSConsole {
        }
    }

    width: 70
    height: 28
    text: "Console"
    onClicked: {
        jsConsole.show()
    }
}
