// Copyright (c) 2021 Aldo Hoeben / fieldOfView
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

    Component.onCompleted:
    {
        is40 = (CuraSDKVersion == "6.0.0")
        isLE44 = (CuraSDKVersion <= "7.0.0")
        isLE46 = (CuraSDKVersion <= "7.2.0")
        isLE410 = (CuraSDKVersion <= "7.6.0") && UM.Application.version != "master"

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
        else
        {
            messageStack = base.contentItem.children[2].children[3].children[8]
        }
        messageStack.anchors.leftMargin = Qt.binding(function()
        {
            return Math.floor((base.width) / 2)
        })

        // adjust stages menu position for sidebar
        var stagesListContainer = mainWindowHeader.children[1]
        stagesListContainer.anchors.leftMargin = Qt.binding(function()
        {
            return Math.floor((base.width - printSetupSelector.width - stagesListContainer.width) / 2)
        })

        // hide application logo if there is no room for it
        var applicationLogo = mainWindowHeader.children[0] // declared as property above
        applicationLogo.visible = Qt.binding(function()
        {
            return stagesListContainer.anchors.leftMargin > applicationLogo.width + 2 * UM.Theme.getSize("default_margin").width
        })
    }

    Cura.MachineSelector
    {
        id: machineSelection
        headerCornerSide: Cura.RoundedRectangle.Direction.All
        width: UM.Theme.getSize("machine_selector_widget").width
        height: UM.Theme.getSize("main_window_header_button").height
        anchors.right: parent.right
        anchors.rightMargin: UM.Theme.getSize("print_setup_widget").width - width
        y: - Math.floor((UM.Theme.getSize("main_window_header").height + height) / 2)

        Component.onCompleted:
        {
            if(isLE410)
            {
                machineSelection.children[1].visible = false // remove shadow
            }

            if(isLE46)
            {
                var machineSelectionHeader = machineSelection.children[0].children[3].children[0]
            } else {
                var machineSelectionHeader = machineSelection.children[0].children[3].children[1]
            }
            // adjust header margins, because the height is smaller than designed
            machineSelectionHeader.anchors.topMargin = 0
            machineSelectionHeader.anchors.bottomMargin = 0
        }
    }
}