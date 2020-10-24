// Copyright (c) 2020 Aldo Hoeben / fieldOfView
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

    property bool is40
    property bool isLE44
    property bool isLE46

    property bool sidebarVisible: UM.Preferences.getValue("view/settings_visible")
    property real sidebarWidth: sidebarVisible ? printSetupSelector.width : 0

    Component.onCompleted:
    {
        is40 = (CuraSDKVersion == "6.0.0")
        isLE44 = (CuraSDKVersion <= "7.0.0")
        isLE46 = (CuraSDKVersion <= "7.2.0") && UM.Application.version != "master"
        if(is40)
        {
             CuraApplication.log("SidebarGUIPlugin patching interface for Cura 4.0")
        }
        else if(isLE44)
        {
             CuraApplication.log("SidebarGUIPlugin patching interface for Cura 4.1 - 4.4")
        }
        else if(isLE46)
        {
             CuraApplication.log("SidebarGUIPlugin patching interface for Cura 4.5 - 4.6")
        }
        else
        {
             CuraApplication.log("SidebarGUIPlugin patching interface for Cura 4.7 and newer")
        }

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
        if(is40)
        {
            messageStack = base.contentItem.children[0].children[3].children[7] // declared as property above
        }
        else if(isLE44)
        {
            messageStack = base.contentItem.children[2].children[3].children[7] // declared as property above
        }
        else
        {
            messageStack = base.contentItem.children[2].children[3].children[8] // declared as property above
        }
        messageStack.anchors.horizontalCenter = undefined
        messageStack.anchors.left = messageStack.parent.left
        messageStack.anchors.leftMargin = Math.floor((base.width - sidebarWidth) / 2)

        // adjust stages menu position for sidebar
        stagesListContainer = mainWindowHeader.children[1] // declared as property above
        stagesListContainer.anchors.horizontalCenter = undefined
        stagesListContainer.anchors.left = stagesListContainer.parent.left
        stagesListContainer.anchors.leftMargin = Math.floor((base.width - sidebarWidth - stagesListContainer.width) / 2)

        // compensate viewport for full-height sidebar
        base.viewportRect = Qt.rect(0, 0, (base.width - sidebarWidth) / base.width, 1.0)

        // make settingview take up available height
        var printSetupContent = printSetupSelector.contentItem
        if(is40)
        {
            printSetupContent.children[1].visible = false // separator line
            printSetupContent.children[2].visible = false // recommended/custom button row
        }
        else
        {
            printSetupContent.children[2].visible = false // separator line
            printSetupContent.children[3].visible = false // recommended/custom button row
        }

        printSetupContent.height = undefined
        printSetupContent.anchors.fill = printSetupContent.parent

        var printSetupChildren = (is40) ? printSetupContent.children[0] : printSetupContent.children[1]
        printSetupChildren.height = undefined // id: contents
        printSetupChildren.anchors.fill = printSetupContent
        printSetupChildren.anchors.bottomMargin = 2 * UM.Theme.getSize("default_lining").height

        var customPrintSetup = printSetupChildren.children[1]

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
            base.viewportRect = Qt.rect(0, 0, (base.width - sidebarWidth) / base.width, 1.0)

            // adjust message stack position for sidebar
            messageStack.anchors.leftMargin = Math.floor((base.width - sidebarWidth) / 2)

            // adjust stages menu position for sidebar
            stagesListContainer.anchors.leftMargin = Math.floor((base.width - sidebarWidth - stagesListContainer.width) / 2)
        }
    }

    Connections
    {
        target: UM.Preferences
        onPreferenceChanged:
        {
            if (preference == "view/settings_visible")
            {
                sidebarVisible = UM.Preferences.getValue("view/settings_visible")
                base.onWidthChanged(base.width)
            }
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
            if(isLE46) {
                var machineSelectionHeader = machineSelection.children[0].children[3].children[0]
            } else {
                var machineSelectionHeader = machineSelection.children[0].children[3].children[1]
            }
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

    PrintSetupSummary
    {
        id: printSetupSummary
        visible: !sidebarVisible

        width: printSetupSelector.width

        anchors
        {
            top: parent.top
            right: bottomRight.right
        }
    }

    SidebarContents
    {
        id: printSetupSidebar
        visible: sidebarVisible

        anchors
        {
            top: parent.top
            bottom: actionRow.top
            bottomMargin: actionRow.height == 0 ? 0 : UM.Theme.getSize("thin_margin").height
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