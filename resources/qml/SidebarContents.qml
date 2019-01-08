// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Cura.RoundedRectangle
{
    border.width: UM.Theme.getSize("default_lining").width
    border.color: UM.Theme.getColor("lining")
    color: UM.Theme.getColor("main_background")

    cornerSide: Cura.RoundedRectangle.Direction.Left
    radius: UM.Theme.getSize("default_radius").width

    width: UM.Theme.getSize("print_setup_widget").width

    Column
    {
        id: settingsHeader
        width: parent.width

        anchors.top: parent.top
        anchors.topMargin: UM.Theme.getSize("default_margin").height

        Item
        {
            width: parent.width
            height: childrenRect.height + UM.Theme.getSize("default_margin").height

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
                    globalProfileSelector.children[0].visible = false // "Profile:" label
                }
            }

            ModeToggleSwitch
            {
                id: modeToggleSwitch
                anchors.right: parent.right
                anchors.rightMargin: UM.Theme.getSize("default_margin").width
            }
        }

        Item
        {
            width: parent.width
            height: extruderSelector.visible ? childrenRect.height : 0

            Rectangle
            {
                width: parent.width
                anchors.bottom: extruderSelector.bottom
                height: UM.Theme.getSize("default_lining").height
                color: UM.Theme.getColor("lining")
                visible: extruderSelector.visible
            }
            ExtruderTabs
            {
                id: extruderSelector

                anchors
                {
                    left: parent.left
                    leftMargin: UM.Theme.getSize("default_margin").width
                    right: showExtruderConfigurationPanel.left
                    rightMargin: UM.Theme.getSize("default_margin").width
                }
            }

            UM.SimpleButton
            {
                id: showExtruderConfigurationPanel
                anchors
                {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: UM.Theme.getSize("wide_margin").width + UM.Theme.getSize("narrow_margin").width
                }
                iconSource: UM.Theme.getIcon("pencil")
                width: UM.Theme.getSize("standard_arrow").width
                height: UM.Theme.getSize("standard_arrow").height
                color: UM.Theme.getColor("setting_category_text")

                onClicked: extruderConfiguration.visible = !extruderConfiguration.visible
                visible: extruderSelector.visible
            }
        }

        Item
        {
            id: extruderConfiguration
            visible: false
            width: parent.width
            height: visible ? childrenRect.height : 0
            children: [ configurationMenu.contentItem ]

            Behavior on height { NumberAnimation { duration: 100 } }

            Cura.ConfigurationMenu
            {
                id: configurationMenu
                visible: false

                Component.onCompleted:
                {
                    var customConfiguration = configurationMenu.contentItem.children[0].children[1];
                    customConfiguration.children[2].visible = false // extruder tabs
                }
            }

            Connections
            {
                target: extruderSelector
                onVisibleChanged:
                {
                    if (!extruderSelector.visible)
                    {
                        extruderConfiguration.visible = false
                    }
                }
            }
        }
    }

    // This is a work around to prevent the printSetupSelector from having to be re-loaded every time
    // a stage switch is done.
    Item
    {
        id: settingsViewContainer
        children: [ printSetupSelector.contentItem ]
        anchors
        {
            top: settingsHeader.bottom
            bottom: parent.bottom
        }
        width: parent.width
    }
}
