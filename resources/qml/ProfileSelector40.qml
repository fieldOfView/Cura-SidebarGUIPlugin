// Copyright (c) 2020 Aldo Hoeben / fieldOfView
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
        anchors.right: dockButton.left
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
    }

    UM.SimpleButton
    {
        id: dockButton
        anchors
        {
            top: parent.top
            topMargin: UM.Theme.getSize("default_margin").width

            right: collapseButton.left
            rightMargin: UM.Theme.getSize("thin_margin").width
        }
        iconSource: UM.Theme.getIcon("cross2")
        width: UM.Theme.getSize("default_arrow").width
        height: UM.Theme.getSize("default_arrow").height
        color: UM.Theme.getColor("small_button_text")

        onClicked:
        {
            UM.Preferences.setValue("sidebargui/docked_sidebar", !UM.Preferences.getValue("sidebargui/docked_sidebar"))
        }
    }

    UM.SimpleButton
    {
        id: collapseButton
        anchors
        {
            top: parent.top
            topMargin: UM.Theme.getSize("default_margin").width

            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }
        iconSource: UM.Theme.getIcon("cross1")
        width: UM.Theme.getSize("default_arrow").width
        height: UM.Theme.getSize("default_arrow").height
        color: UM.Theme.getColor("small_button_text")

        onClicked:
        {
            UM.Preferences.setValue("view/settings_visible", false)
        }
    }
}
