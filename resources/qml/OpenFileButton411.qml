// Copyright (c) 2020 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Button
{
    id: openFileButton

    height: UM.Theme.getSize("button").height
    width: height + 4 * UM.Theme.getSize("default_lining").width // There's some magic going on here
    onClicked: Cura.Actions.open.trigger()
    hoverEnabled: true

    contentItem: Rectangle
    {
        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.getSize("thin_margin").width

        opacity: parent.enabled ? 1.0 : 0.2
        radius: Math.round(width * 0.5)

        color:
        {
            if(parent.hovered)
            {
                return UM.Theme.getColor("toolbar_button_hover")
            }
            return UM.Theme.getColor("toolbar_background")
        }

        UM.RecolorImage
        {
            id: buttonIcon
            anchors.centerIn: parent
            width: parent.width - UM.Theme.getSize("default_margin").width
            height: parent.height - UM.Theme.getSize("default_margin").height
            source: UM.Theme.getIcon("load")
            color: UM.Theme.getColor("icon")

            sourceSize.height: height
        }
    }

    background: Cura.RoundedRectangle
    {
        id: background
        height: UM.Theme.getSize("button").height
        width: UM.Theme.getSize("button").width + UM.Theme.getSize("narrow_margin").width

        radius: UM.Theme.getSize("default_radius").width
        cornerSide: Cura.RoundedRectangle.Direction.Right

        color: UM.Theme.getColor("toolbar_background")
        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("lining")
    }
}
