// Copyright (c) 2018 fieldOfView
// SidebarGUI is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

import QtGraphicalEffects 1.0 // For the dropshadow

Item
{
    id: stageMenu

    signal showTooltip(Item item, point location, string text)
    signal hideTooltip()

    Connections
    {
        target: printSetupSelector
        onExpandedChanged:
        {
            var rect = Qt.rect(0, 0, 1, 1);
            if(printSetupSelector.expanded)
            {
                rect = Qt.rect(0, 0, (base.width - printSetupSelector.width) / base.width, 1.0);
            }
            base.viewportRect = rect;
        }
    }

    Component.onCompleted:
    {
        // top-align toolbar (defined in Cura.qml)
        toolbar.anchors.verticalCenter = undefined
        toolbar.anchors.top = toolbar.parent.top
        toolbar.anchors.topMargin = UM.Theme.getSize("stage_menu").height + UM.Theme.getSize("default_margin").height
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
        height: UM.Theme.getSize("stage_menu").height
        width: UM.Theme.getSize("stage_menu").height
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

        background: Rectangle
        {
            id: background
            height: UM.Theme.getSize("stage_menu").height
            width: UM.Theme.getSize("stage_menu").height

            radius: UM.Theme.getSize("default_radius").width
            color: openFileButton.hovered ? UM.Theme.getColor("action_button_hovered") : UM.Theme.getColor("action_button")
        }

        DropShadow
        {
            id: shadow
            // Don't blur the shadow
            radius: 0
            anchors.fill: background
            source: background
            verticalOffset: 2
            visible: true
            color: UM.Theme.getColor("action_button_shadow")
            // Should always be drawn behind the background.
            z: background.z - 1
        }
    }

    Cura.MachineSelector
    {
        id: machineSelection
        headerCornerSide: Cura.RoundedRectangle.Direction.All
        width: UM.Theme.getSize("machine_selector_widget").width
        height: parent.height
        anchors.centerIn: parent
    }

    // Item to ensure that all of the buttons are nicely centered.
    Row
    {
        anchors.right: parent.right
        width: childrenRect.width
        height: parent.height

        Loader
        {
            id: viewPanel
            height: parent.height
            width: UM.Theme.getSize("layerview_menu_size").width
            visible: false
            source:
            {
                if(UM.Controller.activeView != null && UM.Controller.activeView.stageMenuComponent != null)
                {
                    return UM.Controller.activeView.stageMenuComponent;
                }
                return "StageLegend.qml";
            }
        }

        property string activeStage:
        {
            var stageString = UM.Controller.activeStage + "";
            return stageString.substr(0, stageString.indexOf("("));
        }

        Rectangle
        {
            border.width: UM.Theme.getSize("default_lining").width
            border.color: UM.Theme.getColor("lining")
            color: UM.Theme.getColor("main_background")

            children: [viewPanel.item.contentItem]
            height: childrenRect.height + (parent.activeStage != "PrepareStage" ? 2 : 1) * UM.Theme.getSize("default_margin").height
            width: childrenRect.width + UM.Theme.getSize("default_margin").width
            y: viewPanel.height + UM.Theme.getSize("wide_lining").height
        }

        Item
        {
            height: parent.height
            width: UM.Theme.getSize("default_margin").width
        }

        Item
        {
            id: printSetupSelectorItem
            // This is a work around to prevent the printSetupSelector from having to be re-loaded every time
            // a stage switch is done.
            children: [printSetupSelector]
            height: childrenRect.height
            width: childrenRect.width
        }
    }
}