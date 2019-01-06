// Copyright (c) 2018 fieldOfView
// SidebarGUI is released under the terms of the AGPLv3 or higher.

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

        // hide default action panel widget
        var actionPanelWidget = base.contentItem.children[0].children[3].children[5]
        actionPanelWidget.visible = false

        // adjust message stack position for sidebar
        messageStack = base.contentItem.children[0].children[3].children[8]
        messageStack.anchors.horizontalCenter = undefined
        messageStack.anchors.left = messageStack.parent.left
        messageStack.anchors.leftMargin = Math.floor((base.width - printSetupSelector.width) / 2)

        // adjust stages menu position for sidebar
        stagesListContainer = mainWindowHeader.children[1]
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

        customPrintSetup.children[1].visible = false // extruder tabs
        customPrintSetup.children[0].visible = false // profile selector
        customPrintSetup.children[0].height = 0
        customPrintSetup.children[2].anchors.rightMargin = 0
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

    UM.I18nCatalog
    {
        id: catalog
        name: "cura"
    }

    Button
    {
        id: openFileButton

        anchors.left: parent.left
        anchors.leftMargin: 0
        height: UM.Theme.getSize("button").height
        width: height
        onClicked: Cura.Actions.open.trigger()
        hoverEnabled: true

        contentItem: Item
        {
            anchors.fill: parent
            UM.RecolorImage
            {
                id: buttonIcon
                anchors.centerIn: parent
                source: UM.Theme.getIcon("load")
                width: UM.Theme.getSize("button_icon").width
                height: UM.Theme.getSize("button_icon").height
                color: UM.Theme.getColor("icon")

                sourceSize.height: height
            }
        }

        background: Cura.RoundedRectangle
        {
            id: background
            height: UM.Theme.getSize("stage_menu").height
            width: UM.Theme.getSize("stage_menu").height

            radius: UM.Theme.getSize("default_radius").width
            cornerSide: Cura.RoundedRectangle.Direction.Right
            color: openFileButton.hovered ? UM.Theme.getColor("action_button_hovered") : UM.Theme.getColor("action_button")
            border.width: UM.Theme.getSize("default_lining").width
            border.color: UM.Theme.getColor("lining")
        }
    }

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

    Item {
        // hidden items
        visible: false

        Cura.ViewOrientationControls {
            id: viewPanelOrientationControls
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Loader
        {
            id: viewMenuComponent
            height: parent.height
            width: UM.Theme.getSize("layerview_menu_size").width
            source:
            {
                if(UM.Controller.activeView != null && UM.Controller.activeView.stageMenuComponent != null)
                {
                    return UM.Controller.activeView.stageMenuComponent;
                }
                return "StageLegend.qml";
            }
        }
    }

    property string activeStage:
    {
        var stageString = UM.Controller.activeStage + "";
        return stageString.substr(0, stageString.indexOf("("));
    }

    Rectangle
    {
        id: viewOptionsFloater
        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("lining")
        color: UM.Theme.getColor("main_background")
        radius: UM.Theme.getSize("default_radius").width

        Column
        {
            id: viewOptions
            spacing: UM.Theme.getSize("thin_margin").height
            children:
            [
                viewPanelOrientationControls,
                viewMenuComponent.item.contentItem
            ]
            anchors.top: parent.top
            anchors.topMargin: UM.Theme.getSize("default_margin").height
        }

        height: viewOptions.height + (activeStage != "PrepareStage" ? 2 : 1) * UM.Theme.getSize("default_margin").height
        width: UM.Theme.getSize("layerview_menu_size").width

        y: Math.floor(UM.Theme.getSize("stage_menu").height / 2) + UM.Theme.getSize("default_margin").height
        anchors.right: printSetupSidebar.left
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
    }

    Cura.RoundedRectangle
    {
        id: printSetupSidebar

        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("lining")
        color: UM.Theme.getColor("main_background")

        cornerSide: Cura.RoundedRectangle.Direction.Left
        radius: UM.Theme.getSize("default_radius").width

        Column
        {
            id: settingsHeader
            width: parent.width

            anchors.top: parent.top
            anchors.topMargin: UM.Theme.getSize("default_margin").height

            Item
            {
                width: parent.width
                height: childrenRect.height

                Cura.GlobalProfileSelector
                {
                    id: globalProfileSelector
                    visible: printSetupSelector.contentItem.currentModeIndex == Cura.PrintSetupSelectorContents.Mode.Custom
                    anchors
                    {
                        right: modeToggleSwitch.left
                        rightMargin: UM.Theme.getSize("default_margin").width
                    }

                    Component.onCompleted:
                    {
                        globalProfileSelector.children[0].visible = false
                    }
                }

                ModeToggleSwitch
                {
                    id: modeToggleSwitch
                    anchors.right: parent.right
                    anchors.rightMargin: UM.Theme.getSize("default_margin").width
                }
            }

            // TODO: add
            //   extruder tabs
            //   material/variant selection
        }

        // This is a work around to prevent the printSetupSelector from having to be re-loaded every time
        // a stage switch is done.
        Item
        {
            id: settingsViewContainer
            children: [
                printSetupSelector.contentItem
            ]
            anchors
            {
                top: settingsHeader.bottom
                bottom: parent.bottom
            }
            width: parent.width
        }
        anchors
        {
            top: parent.top
            bottom: actionRow.top
            bottomMargin: UM.Theme.getSize("thin_margin").height
            right: bottomRight.right
        }
        width: UM.Theme.getSize("print_setup_widget").width
    }

    Cura.RoundedRectangle
    {
        id: actionRow

        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("lining")
        color: UM.Theme.getColor("main_background")

        cornerSide: Cura.RoundedRectangle.Direction.Left
        radius: UM.Theme.getSize("default_radius").width

        Cura.ActionPanelWidget
        {
            id: actionPanelWidget
            visible: CuraApplication.platformActivity
            width: parent.width
            anchors.bottom: parent.bottom
        }

        anchors.bottom: bottomRight.bottom
        anchors.right: bottomRight.right
        width: UM.Theme.getSize("print_setup_widget").width
        height: CuraApplication.platformActivity ? actionPanelWidget.height : 0
    }

    Item
    {
        id: bottomRight
        anchors.right: parent.right
        y: base.height - stageMenu.mapToItem(base.contentItem, 0, 0).y - height
    }
}