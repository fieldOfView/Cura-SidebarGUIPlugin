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
}
