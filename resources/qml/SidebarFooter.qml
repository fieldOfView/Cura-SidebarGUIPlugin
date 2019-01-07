// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Cura.RoundedRectangle
{
    id: actionRow

    anchors.bottom: bottomRight.bottom
    anchors.right: bottomRight.right

    border.width: UM.Theme.getSize("default_lining").width
    border.color: UM.Theme.getColor("lining")
    color: UM.Theme.getColor("main_background")

    cornerSide: Cura.RoundedRectangle.Direction.Left
    radius: UM.Theme.getSize("default_radius").width

    Cura.ActionPanelWidget
    {
        id: actionPanelWidget
        visible: CuraApplication.platformActivity
        width: parent.width
        anchors.bottom: parent.bottom
    }

    width: UM.Theme.getSize("print_setup_widget").width
    height: CuraApplication.platformActivity ? actionPanelWidget.height : 0
}
