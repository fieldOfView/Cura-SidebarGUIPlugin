// Copyright (c) 2018 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Button
{
    id: openFileButton

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
