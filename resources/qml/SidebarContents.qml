// Copyright (c) 2023 Aldo Hoeben / fieldOfView
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
                if(isLE43) {
                    return "ProfileSelector40.qml";
                } else if(isLE413) {
                    return "ProfileSelector44.qml";
                } else if(isLE50) {
                    return "ProfileSelector50.qml";
                } else if(isLE52) {
                    return "ProfileSelector51.qml";
                } else {
                    return "ProfileSelector53.qml";
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
                    if(isLE410) {
                        return "ExtruderTabs40.qml";
                    } else if (isLE413) {
                        return "ExtruderTabs411.qml";
                    } else {
                        return "ExtruderTabs50.qml";
                    }
                }
            }

            UM.SimpleButton
            {
                id: showExtruderConfigurationPanel
                anchors
                {
                    right: parent.right
                    rightMargin: UM.Theme.getSize("default_margin").width
                    verticalCenter: parent.verticalCenter
                }
                iconSource:
                {
                    if (isLE410) {
                        return extruderConfiguration.visible ? UM.Theme.getIcon("arrow_bottom") : UM.Theme.getIcon("arrow_left")
                    }
                    return extruderConfiguration.visible ? UM.Theme.getIcon("ChevronSingleDown") : UM.Theme.getIcon("ChevronSingleLeft")
                }
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

                property var selectors
                property var enabledCheckbox

                Component.onCompleted:
                {
                    configurationMenu.contentItem.children[1].visible = false // separator
                    if(isLE413)
                    {
                        configurationMenu.contentItem.children[0].x = 2 * UM.Theme.getSize("default_margin").width // extruder config
                        configurationMenu.contentItem.children[2].x = UM.Theme.getSize("default_margin").width // Custom/Configurations
                    }

                    var autoConfiguration = configurationMenu.contentItem.children[0].children[0];
                    autoConfiguration.children[0].visible = false // "Configurations" label
                    autoConfiguration.children[0].height = 0
                    autoConfiguration.children[1].anchors.topMargin = 0 // configurationListView
                    autoConfiguration.children[1].children[0].anchors.topMargin = 0

                    var customConfiguration = configurationMenu.contentItem.children[0].children[1];
                    customConfiguration.children[0].visible = false // "Custom" label
                    customConfiguration.children[0].height = 0

                    var extruderTabs = customConfiguration.children[1]
                    if (isLE51)
                        extruderTabs = customConfiguration.children[2]
                    extruderTabs.visible = false // extruder tabs
                    extruderTabs.height = 0
                    extruderTabs.anchors.topMargin = 0

                    var customSelectors = customConfiguration.children[2]
                    if (isLE51)
                        customSelectors = customConfiguration.children[3]
                    customSelectors.children[0].visible = false // some spacer rectangle
                    customSelectors.children[0].height = 0

                    selectors = customSelectors.children[1]
                    selectors.padding = 0 // enabled/material/variant column
                    selectors.spacing = UM.Theme.getSize("default_lining").height

                    enabledCheckbox = selectors.children[0].children[1]

                    if (isLE413)
                    {
                        return
                    }

                    materialSelectionLoader.source = "MaterialSelection.qml"
                }

                Loader
                {
                    id: materialSelectionLoader
                    property var configurationMenu: parent
                    onLoaded:
                    {
                        configurationMenu.selectors.children[1].children[1] = item
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
