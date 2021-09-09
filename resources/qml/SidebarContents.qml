// Copyright (c) 2021 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

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

        Loader
        {
            width: parent.width
            height: UM.Theme.getSize("setting_control").height + UM.Theme.getSize("default_margin").height
            source:
            {
                var is44 = (CuraSDKVersion >= "7.0.0");
                if(is44) {
                    return "ProfileSelector44.qml";
                } else {
                    return "ProfileSelector40.qml";
                }
            }
        }

        Item
        {
            width: parent.width
            height: extruderSelector.visible ? extruderSelector.height : 0

            Rectangle
            {
                width: parent.width
                anchors.bottom: extruderSelector.bottom
                height: UM.Theme.getSize("default_lining").height
                color: UM.Theme.getColor("lining")
                visible: extruderSelector.visible && extruderSelector.enabled
            }
            Loader
            {
                id: extruderSelector
                enabled:
                {
                    if (printSetupSelector.contentItem.currentModeIndex == Cura.PrintSetupSelectorContents.Mode.Custom)
                    {
                        return true
                    }
                    else
                    {
                        return extruderConfiguration.visible
                    }
                }

                anchors
                {
                    left: parent.left
                    leftMargin: UM.Theme.getSize("default_margin").width + 5 * UM.Theme.getSize("default_lining").width
                    right: showExtruderConfigurationPanel.left
                    rightMargin: UM.Theme.getSize("default_margin").width + UM.Theme.getSize("default_lining").width
                }

                source:
                {
                    var is411 = (CuraSDKVersion >= "7.7.0");
                    if(is411) {
                        return "ExtruderTabs411.qml";
                    } else {
                        return "ExtruderTabs40.qml";
                    }
                }
            }

            UM.SimpleButton
            {
                id: showExtruderConfigurationPanel
                anchors
                {
                    right: parent.right
                    rightMargin: UM.Theme.getSize("wide_margin").width + UM.Theme.getSize("narrow_margin").width
                    verticalCenter: parent.verticalCenter
                }
                iconSource: extruderConfiguration.visible ? UM.Theme.getIcon("arrow_bottom") : UM.Theme.getIcon("arrow_left")
                width: UM.Theme.getSize("standard_arrow").width
                height: UM.Theme.getSize("standard_arrow").height
                color: UM.Theme.getColor("setting_category_text")

                onClicked:
                {
                    extruderConfiguration.visible = !extruderConfiguration.visible
                    UM.Preferences.setValue("sidebargui/expand_extruder_configuration", extruderConfiguration.visible)
                }
                visible: extruderSelector.visible
            }
        }

        Item
        {
            id: extruderConfiguration
            visible:
            {
                if (extruderSelector.visible)
                {
                    return UM.Preferences.getValue("sidebargui/expand_extruder_configuration")
                }
                return false
            }
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
                    configurationMenu.contentItem.children[1].visible = false // separator

                    var autoConfiguration = configurationMenu.contentItem.children[0].children[0];
                    autoConfiguration.children[0].visible = false // "Configurations" label
                    autoConfiguration.children[0].height = 0
                    autoConfiguration.children[1].anchors.topMargin = 0 // configurationListView
                    autoConfiguration.children[1].children[0].anchors.topMargin = 0

                    var customConfiguration = configurationMenu.contentItem.children[0].children[1];
                    customConfiguration.children[0].visible = false // "Custom" label
                    customConfiguration.children[0].height = 0
                    customConfiguration.children[2].visible = false // extruder tabs
                    customConfiguration.children[2].height = 0
                    customConfiguration.children[2].anchors.topMargin = 0
                    customConfiguration.children[3].children[0].visible = false // some spacer rectangle
                    customConfiguration.children[3].children[0].height = 0
                    customConfiguration.children[3].children[1].padding = 0 // enabled/material/variant column
                    customConfiguration.children[3].children[1].spacing = UM.Theme.getSize("default_lining").height
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
            topMargin: UM.Theme.getSize("default_lining").height
            bottom: parent.bottom
        }
        width: parent.width

        Component.onDestruction:
        {
            //  HACK: This is to ensure that the parent never gets set to null, as this wreaks havoc on the focus.
            printSetupSelector.contentItem.parent = printSetupSelector;
        }
    }
}
