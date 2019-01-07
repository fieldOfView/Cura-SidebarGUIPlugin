// Copyright (c) 2018 fieldOfView
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

    property var messageStack
    property var stagesListContainer

    Component.onCompleted:
    {
        // adjust message stack position for sidebar
        messageStack = base.contentItem.children[0].children[3].children[8]
        messageStack.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width) / 2)

        // adjust stages menu position for sidebar
        stagesListContainer = mainWindowHeader.children[1]
        stagesListContainer.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width - stagesListContainer.width) / 2)
    }

    Connections
    {
        target: base
        onWidthChanged:
        {
            // adjust message stack position for sidebar
            messageStack.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width) / 2)

            // adjust stages menu position for sidebar
            stagesListContainer.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width - stagesListContainer.width) / 2)
        }
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

        Component.onCompleted: {
            machineSelection.children[1].visible = false // remove shadow
            var machineSelectionHeader = machineSelection.children[0].children[3].children[0]
            // adjust header margins, because the height is smaller than designed
            machineSelectionHeader.anchors.topMargin = 0
            machineSelectionHeader.anchors.bottomMargin = 0
        }
    }
}