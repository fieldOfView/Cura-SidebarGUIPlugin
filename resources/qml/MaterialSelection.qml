// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Cura.PrintSetupHeaderButton
{
    id: materialSelection

    property bool valueError: Cura.MachineManager.activeStack !== null ? Cura.ContainerManager.getContainerMetaDataEntry(Cura.MachineManager.activeStack.material.id, "compatible") !== "True" : true
    property bool valueWarning: !Cura.MachineManager.isActiveQualitySupported

    text: Cura.MachineManager.activeStack !== null ? Cura.MachineManager.activeStack.material.name : ""
    tooltip: text
    enabled: (configurationMenu.enabledCheckbox != undefined) ? configurationMenu.enabledCheckbox.checked : false

    height: UM.Theme.getSize("setting_control").height + UM.Theme.getSize("default_margin").height
    width: (configurationMenu.selectors != undefined) ? configurationMenu.selectors.controlWidth : 0

    focusPolicy: Qt.ClickFocus

    MaterialMenu
    {
        id: materialsMenu
        width: materialSelection.width
        extruderIndex: Cura.ExtruderManager.activeExtruderIndex
        updateModels: materialSelection.visible
    }
    onClicked: materialsMenu.popup(0, height - UM.Theme.getSize("default_lining").height)
}
