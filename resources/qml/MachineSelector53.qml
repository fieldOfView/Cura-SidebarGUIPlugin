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

    machineManager: Cura.MachineManager
    onSelectPrinter: function(machine)
    {
        toggleContent();
        Cura.MachineManager.setActiveMachine(machine.id);
    }
    machineListModel: Cura.MachineListModel {}
    buttons: [
        Cura.SecondaryButton
        {
            id: addPrinterButton
            leftPadding: UM.Theme.getSize("default_margin").width
            rightPadding: UM.Theme.getSize("default_margin").width
            text: catalog.i18nc("@button", "Add printer")
            // The maximum width of the button is half of the total space, minus the padding of the parent, the left
            // padding of the component and half the spacing because of the space between buttons.
            fixedWidthMode: true
            width: Math.round(parent.width / 2 - leftPadding * 1.5)
            onClicked:
            {
                machineSelection.toggleContent()
                Cura.Actions.addMachine.trigger()
            }
        },
        Cura.SecondaryButton
        {
            id: managePrinterButton
            leftPadding: UM.Theme.getSize("default_margin").width
            rightPadding: UM.Theme.getSize("default_margin").width
            text: catalog.i18nc("@button", "Manage printers")
            fixedWidthMode: true
            // The maximum width of the button is half of the total space, minus the padding of the parent, the right
            // padding of the component and half the spacing because of the space between buttons.
            width: Math.round(parent.width / 2 - rightPadding * 1.5)
            onClicked:
            {
                machineSelection.toggleContent()
                Cura.Actions.configureMachines.trigger()
            }
        }
    ]

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