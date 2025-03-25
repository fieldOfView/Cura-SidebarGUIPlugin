// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Item
{
    id: stageMenu

    signal showTooltip(Item item, point location, string text)
    signal hideTooltip()

    property bool is40
    property bool isLE44
    property bool isLE46
    property bool isLE410
    property bool isLE413
    property bool isLE51
    property bool isLE52

    Component.onCompleted:
    {
        is40 = (CuraSDKVersion == "6.0.0")
        isLE44 = (CuraSDKVersion <= "7.0.0")
        isLE46 = (CuraSDKVersion <= "7.2.0")
        isLE410 = (CuraSDKVersion <= "7.6.0")
        isLE413 = (CuraSDKVersion <= "7.9.0")
        isLE51 = (CuraSDKVersion <= "8.1.0")
        isLE52 = (CuraSDKVersion <= "8.2.0")

        // adjust message stack position for sidebar
        var messageStack
        if(is40)
        {
            messageStack = base.contentItem.children[0].children[3].children[7]
        }
        else if(isLE44)
        {
            messageStack = base.contentItem.children[2].children[3].children[7]
        }
        else if(isLE413)
        {
            messageStack = base.contentItem.children[2].children[3].children[8]
        }
        else if(isLE52)
        {
            messageStack = base.contentItem.children[3].children[3].children[8]
        }
        else
        {
            messageStack = base.contentItem.children[4].children[3].children[8]
        }
        messageStack.anchors.horizontalCenter = undefined
        messageStack.anchors.left = messageStack.parent.left
        messageStack.anchors.leftMargin = Qt.binding(function()
        {
            return Math.floor((base.width - printSetupSelector.width) / 2)
        })

        // adjust stages menu position for sidebar
        var stagesListContainer = mainWindowHeader.children[1]
        stagesListContainer.anchors.horizontalCenter = undefined
        stagesListContainer.anchors.left = stagesListContainer.parent.left
        stagesListContainer.anchors.leftMargin = Qt.binding(function()
        {
            return Math.floor((base.width - printSetupSelector.width - stagesListContainer.width) / 2)
        })

        // hide application logo if there is no room for it
        var applicationLogo = mainWindowHeader.children[0]
        applicationLogo.visible = Qt.binding(function()
        {
            return stagesListContainer.anchors.leftMargin > applicationLogo.width + 2 * UM.Theme.getSize("default_margin").width
        })
    }

    Loader
    {
        anchors.right: parent.right
        anchors.rightMargin: UM.Theme.getSize("print_setup_widget").width - width
        width: UM.Theme.getSize("machine_selector_widget").width
        height:
        {
            if (isLE413)
            {
                return UM.Theme.getSize("main_window_header_button").height
            } else {
                return Math.round(0.5 * UM.Theme.getSize("main_window_header").height)
            }
        }
        y: - Math.floor((UM.Theme.getSize("main_window_header").height + height) / 2)

        source:
        {
            if(isLE52) {
                return "MachineSelector40.qml";
            } else {
                return "MachineSelector53.qml";
            }
        }
    }
}