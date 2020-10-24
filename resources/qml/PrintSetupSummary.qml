// Copyright (c) 2020 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Cura.RoundedRectangle
{
    color: mouseArea.containsMouse ? UM.Theme.getColor("action_button_hovered") : UM.Theme.getColor("action_button")
    border.width: UM.Theme.getSize("default_lining").width
    border.color: UM.Theme.getColor("lining")
    radius: UM.Theme.getSize("default_radius").width
    cornerSide: Cura.RoundedRectangle.Direction.Left

    height: printSetupSummary.height + extruderSummary.height + 3 * UM.Theme.getSize("default_margin").height

    Cura.PrintSetupSelectorHeader
    {
        id: printSetupSummary

        anchors
        {
            left: parent.left
            right: collapseButton.left
            top: parent.top

            leftMargin: UM.Theme.getSize("default_margin").width
            topMargin: UM.Theme.getSize("default_margin").width
        }
    }

    UM.RecolorImage
    {
        id: collapseButton
        anchors
        {
            verticalCenter: printSetupSummary.verticalCenter

            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }
        source: UM.Theme.getIcon("pencil")
        visible: source != ""
        width: UM.Theme.getSize("action_button_icon").width
        height: UM.Theme.getSize("action_button_icon").height
        color: UM.Theme.getColor("small_button_text")
    }

    ExtruderTabs
    {
        id: extruderSummary
        enabled: false

        anchors
        {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: UM.Theme.getSize("default_margin").width
            rightMargin: UM.Theme.getSize("default_margin").width
            bottomMargin: UM.Theme.getSize("default_margin").width
        }
    }

    MouseArea
    {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent

        onClicked:
        {
            UM.Preferences.setValue("view/settings_visible", true)
        }
    }
}
