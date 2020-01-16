// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Item
{
    width: parent.width
    height: UM.Theme.getSize("setting_control").height + UM.Theme.getSize("default_margin").height

    Cura.GlobalProfileSelector
    {
        id: globalProfileSelector
        visible: printSetupSelector.contentItem.currentModeIndex == Cura.PrintSetupSelectorContents.Mode.Custom
        anchors
        {
            left: parent.left
            right: modeToggleSwitch.left
            rightMargin: UM.Theme.getSize("default_margin").width
        }

        Component.onCompleted:
        {
            globalProfileSelector.children[0].visible = false // "Profile:" label
            // dropdown
            globalProfileSelector.children[1].width = parent.width - modeToggleSwitch.width -
                (2 * UM.Theme.getSize("default_margin").width + UM.Theme.getSize("thick_margin").width - 3 * UM.Theme.getSize("default_lining").width)
        }
    }

    ModeToggleSwitch
    {
        id: modeToggleSwitch
        anchors.right: parent.right
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
    }
}