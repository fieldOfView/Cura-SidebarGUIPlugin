// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Cura.MachineSelector
{
    id: machineSelection
    headerCornerSide: Cura.RoundedRectangle.Direction.All

    Component.onCompleted:
    {
        if(isLE410)
        {
            machineSelection.children[1].visible = false // remove shadow
        }

        if(isLE46)
        {
            var machineSelectionHeader = machineSelection.children[0].children[3].children[0]
        } else {
            var machineSelectionHeader = machineSelection.children[0].children[3].children[1]
        }
        // adjust header margins, because the height is smaller than designed
        machineSelectionHeader.anchors.topMargin = 0
        machineSelectionHeader.anchors.bottomMargin = 0
    }
}