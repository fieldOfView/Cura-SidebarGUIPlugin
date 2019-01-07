// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Switch
{
    id: modeToggleSwitch
    text: catalog.i18nc("@button", "Custom")
    checked: printSetupSelector.contentItem.currentModeIndex == Cura.PrintSetupSelectorContents.Mode.Custom

    onCheckedChanged: printSetupSelector.contentItem.currentModeIndex = checked ? Cura.PrintSetupSelectorContents.Mode.Custom : Cura.PrintSetupSelectorContents.Mode.Recommended;

    indicator: Rectangle
    {
        implicitWidth: Math.floor(implicitHeight * 1.5)
        implicitHeight: UM.Theme.getSize("checkbox").height
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: modeToggleSwitch.checked ? UM.Theme.getColor("primary") : UM.Theme.getColor("main_background")
        border.color: modeToggleSwitch.checked ? UM.Theme.getColor("primary") : UM.Theme.getColor("setting_control_border")

        Behavior on color { ColorAnimation { duration: 100 } }

        Rectangle
        {
            x: modeToggleSwitch.checked ? parent.width - width : 0
            width: height
            height: parent.implicitHeight
            radius: height / 2
            color: UM.Theme.getColor("main_background")
            border.color: UM.Theme.getColor("setting_control_border")

            Behavior on x { NumberAnimation { duration: 100 } }
        }
    }

    contentItem: Label
    {
        text: modeToggleSwitch.text
        verticalAlignment: Text.AlignVCenter
        height: parent.height
        font: UM.Theme.getFont("default")
        color: UM.Theme.getColor("text")
        renderType: Text.NativeRendering
        leftPadding: modeToggleSwitch.indicator.width
    }
}
