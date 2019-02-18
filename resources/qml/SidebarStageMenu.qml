// Copyright (c) 2019 fieldOfView
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
        // top-align toolbar (defined in Cura.qml)
        toolbar.visible = true
        toolbar.anchors.verticalCenter = undefined
        toolbar.anchors.top = toolbar.parent.top
        toolbar.anchors.topMargin = UM.Theme.getSize("stage_menu").height + UM.Theme.getSize("default_margin").height

        // hide view orientation controls (shown them in viewpanel instead)
        viewOrientationControls.visible = false
        viewOrientationControls.height = 0
        viewOrientationControls.anchors.margins = 0

        // adjust message stack position for sidebar
        messageStack = base.contentItem.children[0].children[3].children[7] // declared as property above
        messageStack.anchors.horizontalCenter = undefined
        messageStack.anchors.left = messageStack.parent.left
        messageStack.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width) / 2)

        // adjust stages menu position for sidebar
        stagesListContainer = mainWindowHeader.children[1] // declared as property above
        stagesListContainer.anchors.horizontalCenter = undefined
        stagesListContainer.anchors.left = stagesListContainer.parent.left
        stagesListContainer.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width - stagesListContainer.width) / 2)

        // compensate viewport for full-height sidebar
        base.viewportRect = Qt.rect(0, 0, (base.width - printSetupSelector.width) / base.width, 1.0)

        // make settingview take up available height
        var printSetupContent = printSetupSelector.contentItem
        printSetupContent.children[1].visible = false // separator line
        printSetupContent.children[2].visible = false // recommended/custom button row

        printSetupContent.height = undefined
        printSetupContent.anchors.fill = printSetupContent.parent

        printSetupContent.children[0].height = undefined // id: contents
        printSetupContent.children[0].anchors.fill = printSetupContent
        printSetupContent.children[0].anchors.bottomMargin = 2 * UM.Theme.getSize("default_lining").height

        var customPrintSetup = printSetupContent.children[0].children[1]
        customPrintSetup.padding = UM.Theme.getSize("narrow_margin").width - UM.Theme.getSize("default_lining").width
        customPrintSetup.height = undefined
        customPrintSetup.anchors.fill = customPrintSetup.parent

        customPrintSetup.children[2].height = undefined // rectangle containing settingview
        customPrintSetup.children[2].anchors.fill = customPrintSetup

        customPrintSetup.children[1].visible = false // extruder tabs
        customPrintSetup.children[0].visible = false // profile selector
        customPrintSetup.children[0].height = 0
        customPrintSetup.children[2].anchors.rightMargin = 0

        // tweak header height
        headerBackground.height = mainWindowHeader.height + UM.Theme.getSize("default_margin").height
        main.anchors.top = main.parent.top
        main.anchors.topMargin = UM.Theme.getSize("default_margin").height
    }

    Connections
    {
        target: base
        onWidthChanged:
        {
            // compensate viewport for full-height sidebar
            base.viewportRect = Qt.rect(0, 0, (base.width - printSetupSelector.width) / base.width, 1.0)

            // adjust message stack position for sidebar
            messageStack.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width) / 2)

            // adjust stages menu position for sidebar
            stagesListContainer.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width - stagesListContainer.width) / 2)
        }
    }

    OpenFileButton {}

    Cura.MachineSelector
    {
        id: machineSelection
        headerCornerSide: Cura.RoundedRectangle.Direction.All
        width: UM.Theme.getSize("machine_selector_widget").width
        height: UM.Theme.getSize("main_window_header_button").height
        anchors.left: printSetupSidebar.left
        y: - Math.floor((UM.Theme.getSize("main_window_header").height + height) / 2)

        Component.onCompleted: {
            machineSelection.children[1].visible = false // remove shadow
            var machineSelectionHeader = machineSelection.children[0].children[3].children[0]
            // adjust header margins, because the height is smaller than designed
            machineSelectionHeader.anchors.topMargin = 0
            machineSelectionHeader.anchors.bottomMargin = 0
        }
    }

    ViewOptionsPanel
    {
        id: viewOptionsPanel

        anchors.right: printSetupSidebar.left
        anchors.rightMargin: UM.Theme.getSize("default_margin").width

        y: Math.floor(UM.Theme.getSize("stage_menu").height / 2)
    }

    SidebarContents
    {
        id: printSetupSidebar

        anchors
        {
            top: parent.top
            bottom: actionRow.top
            bottomMargin: UM.Theme.getSize("thin_margin").height
            right: bottomRight.right
        }
    }

    SidebarFooter
    {
        id: actionRow

        anchors.bottom: bottomRight.bottom
        anchors.right: bottomRight.right
    }

    Item
    {
        id: bottomRight
        anchors.right: parent.right
        y: base.height - stageMenu.mapToItem(base.contentItem, 0, 0).y - height
    }
}