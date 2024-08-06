// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

/*
# 文件概述

官方示例: Qt Quick Examples - Drag and Drop.

采用Drag.Internal, 原文件不能直接处理onDropped()事件, 因此做了些改动

*/

//! [0]
Item {
    id: root

    required property string colorKey
    required property int modelData

    width: 64
    height: 64

    Rectangle {
        anchors.fill: parent
        color: "yellow"
        MouseArea {
            id: mouseArea

            width: 64
            height: 64
            anchors.centerIn: parent

            drag.target: tile

            onReleased: {
                parent = tile.Drag.target !== null ? tile.Drag.target : root
                // add start
                console.log("tile.Drag.active: "+tile.Drag.active)
                tile.Drag.drop()
                console.log("tile.Drag.active: "+tile.Drag.active)
                // add end
            }
            onPressed: {
                // add start
                console.log("tile.Drag.active: "+tile.Drag.active)
                tile.Drag.start()
                console.log("tile.Drag.active: "+tile.Drag.active)
                // add end
            }

            Rectangle {
                id: tile

                width: 64
                height: 64
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                color: root.colorKey

                Drag.keys: [ root.colorKey ]
                // add start
                // onPressed处理后可不手动绑定Drag.active, 会交由tile.Drag.start()等处理
                // add end
                // Drag.active: mouseArea.drag.active
                // Drag.dragType: Drag.Automatic
                Drag.hotSpot.x: 32
                Drag.hotSpot.y: 32
    //! [0]
                Text {
                    anchors.fill: parent
                    color: "white"
                    font.pixelSize: 48
                    text: root.modelData + 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
    //! [1]
                states: State {
                    when: mouseArea.drag.active
                    AnchorChanges {
                        target: tile
                        anchors {
                            verticalCenter: undefined
                            horizontalCenter: undefined
                        }
                    }
                }
            }
        }
    }
}
//! [1]

