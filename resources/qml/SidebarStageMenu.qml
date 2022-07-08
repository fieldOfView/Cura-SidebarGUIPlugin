// Copyright (c) 2022 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Item
{
    id: stageMenu

    property bool is40
    property bool isLE44
    property bool isLE46
    property bool isLE410
    property bool isLE413

    property bool prepareStageActive: UM.Controller.activeStage.toString().indexOf("PrepareStage") == 0
    property bool preSlicedData: PrintInformation !== null && PrintInformation.preSliced
    property bool settingsVisible: UM.Preferences.getValue("view/settings_visible")
    property bool settingsDocked: UM.Preferences.getValue("sidebargui/docked_sidebar")
    property bool sidebarVisible: settingsVisible && (prepareStageActive || !preSlicedData) && settingsDocked
    property real sidebarWidth: sidebarVisible ? printSetupSelector.width : 0

    property var printSetupTooltip

    Component.onCompleted:
    {
        is40 = (CuraSDKVersion == "6.0.0")
        isLE44 = (CuraSDKVersion <= "7.0.0")
        isLE46 = (CuraSDKVersion <= "7.2.0")
        isLE410 = (CuraSDKVersion <= "7.6.0")
        isLE413 = (CuraSDKVersion <= "7.9.0") && UM.Application.version != "master" && UM.Application.version != "dev"
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
        else if(isLE410)
        {
             CuraApplication.log("SidebarGUIPlugin patching interface for Cura 4.7 - 4.9")
        }
        else if(isLE413)
        {
             CuraApplication.log("SidebarGUIPlugin patching interface for Cura 4.10 - 4.13")
        }
        else
        {
             CuraApplication.log("SidebarGUIPlugin patching interface for Cura 5.0 and newer")
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
        else
        {
            messageStack = base.contentItem.children[3].children[3].children[8]
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

        // compensate viewport for full-height sidebar
        base.viewportRect = Qt.binding(function()
        {
            return Qt.rect(0, 0, (base.width - sidebarWidth) / base.width, 1.0)
        })


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

        printSetupTooltip = tooltip // defined in Cura.qml
    }

    Connections
    {
        target: tooltip
        enabled: !settingsDocked
        onOpacityChanged: function()
        {
            if(tooltip.opacity == 0)
            {
                sidebarToolWindow.hideTooltip()
            }
            else if(tooltip.opacity == 1)
            {
                sidebarToolWindow.showTooltip()
            }
        }
        onTextChanged: function()
        {
            sidebarToolWindow.toolTipText =  tooltip.text
        }
        onTargetChanged: function()
        {
            sidebarToolWindow.toolTipY = tooltip.target.y
        }
    }

    Loader
    {
        anchors.left: parent.left
        anchors.leftMargin: -UM.Theme.getSize("default_lining").width
        source:
        {
            if(isLE410) {
                return "OpenFileButton40.qml";
            } else if(isLE413) {
                return "OpenFileButton411.qml";
            } else {
                return "OpenFileButton50.qml";
            }
        }
    }

    Cura.MachineSelector
    {
        id: machineSelection
        headerCornerSide: Cura.RoundedRectangle.Direction.All
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
        anchors.left: printSetupSidebar.left
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

    Loader
    {
        id: viewOptionsPanel

        anchors.right: printSetupSidebar.left
        anchors.rightMargin: UM.Theme.getSize("default_margin").width

        source:
        {
            if(isLE413) {
                return "ViewOptionsPanel40.qml";
            } else {
                return "ViewOptionsPanel50.qml";
            }
        }
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

    Item
    {
        id: printSetupSidebar
        visible: sidebarVisible

        width: UM.Theme.getSize("print_setup_widget").width
        anchors
        {
            top: parent.top
            bottom: actionRow.top
            bottomMargin: actionRow.height == 0 ? 0 : UM.Theme.getSize("thin_margin").height
            right: bottomRight.right
        }

        children:[sidebarContents]
    }

    SidebarContents
    {
        id: sidebarContents
        anchors.fill: parent
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

    SidebarToolWindow
    {
        id: sidebarToolWindow
        onClosing:
        {
            // tool window is closed by window manager (not via our collapse button)
            UM.Preferences.setValue("view/settings_visible", false)
            stageMenu.settingsVisible = false

            printSetupTooltip.visible = true
        }
    }
}