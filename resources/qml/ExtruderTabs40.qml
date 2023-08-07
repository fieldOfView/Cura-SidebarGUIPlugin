// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

TabRow
{
    id: tabBar

    property var extrudersModel: CuraApplication.getExtrudersModel()
    property bool hasMaterials:
    {
        if (CuraSDKVersion >= "6.2.0") {
            return (Cura.MachineManager.activeMachine != null) ? Cura.MachineManager.activeMachine.hasMaterials : false
        } else {
            return Cura.MachineManager.hasMaterials
        }
    }
    property bool hasVariants:
    {
        if (CuraSDKVersion >= "6.2.0") {
            return (Cura.MachineManager.activeMachine != null) ? Cura.MachineManager.activeMachine.hasVariants : false
        } else {
            return Cura.MachineManager.hasVariants
        }
    }

    visible: hasMaterials || hasVariants
    width: parent.width

    Repeater
    {
        id: repeater
        model: extrudersModel
        delegate: TabRowButton
        {
            contentItem: Item
            {
                Cura.ExtruderIcon
                {
                    id: extruderIcon
                    materialColor: model.color
                    extruderEnabled: model.enabled

                    anchors.left: parent.left
                    height: parent.height
                    width: height
                }

                // Label for the brand of the material
                Label
                {
                    id: typeAndBrandNameLabel

                    text: model.material_brand + " " + model.material
                    elide: Text.ElideRight
                    font: UM.Theme.getFont("default")
                    color: UM.Theme.getColor("text")
                    renderType: Text.NativeRendering
                    wrapMode: Text.NoWrap
                    visible: hasMaterials

                    anchors
                    {
                        top: extruderIcon.top
                        left: extruderIcon.right
                        leftMargin: UM.Theme.getSize("default_margin").width
                        right: configurationWarning.left
                        rightMargin: UM.Theme.getSize("default_margin").width
                    }
                }

                // Label that shows the name of the variant
                Label
                {
                    id: variantLabel

                    text: model.variant
                    elide: Text.ElideRight
                    font: UM.Theme.getFont("default_bold")
                    color: UM.Theme.getColor("text")
                    renderType: Text.NativeRendering
                    wrapMode: Text.NoWrap
                    visible: hasVariants

                    anchors
                    {
                        left: extruderIcon.right
                        leftMargin: UM.Theme.getSize("default_margin").width
                        top: typeAndBrandNameLabel.bottom
                    }
                }

                UM.RecolorImage
                {
                    id: configurationWarning

                    property var extruderStack:
                    {
                        if (CuraSDKVersion >= "7.0.0") {
                            return (Cura.MachineManager.activeMachine != null) ? Cura.MachineManager.activeMachine.extruderList[model.index] : undefined;
                        } else if (CuraSDKVersion >= "6.2.0") {
                            return (Cura.MachineManager.activeMachine != null) ? Cura.MachineManager.activeMachine.extruders[model.index] : undefined;
                        } else {
                            return Cura.MachineManager.getExtruder(model.index);
                        }
                    }
                    property bool valueWarning: !SidebarGUIPlugin.getExtruderHasQualityForMaterial(extruderStack)
                    property bool valueError: extruderStack == undefined ? false : Cura.ContainerManager.getContainerMetaDataEntry(extruderStack.material.id, "compatible", "") != "True"

                    visible: (tabBar.hasMaterials || tabBar.hasVariants) && (valueWarning || valueError)

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    source: valueError ? UM.Theme.getIcon("cross2") : UM.Theme.getIcon("warning")
                    color: valueError ? UM.Theme.getColor("setting_validation_error_background") : UM.Theme.getColor("setting_validation_warning_background")
                    width: visible ? UM.Theme.getSize("section_icon").width : 0
                    height: width
                }
            }
            onClicked:
            {
                Cura.ExtruderManager.setActiveExtruderIndex(tabBar.currentIndex)
            }
        }
    }

    //When active extruder changes for some other reason, switch tabs.
    //Don't directly link currentIndex to Cura.ExtruderManager.activeExtruderIndex!
    //This causes a segfault in Qt 5.11. Something with VisualItemModel removing index -1. We have to use setCurrentIndex instead.
    Connections
    {
        target: Cura.ExtruderManager
        onActiveExtruderChanged:
        {
            tabBar.setCurrentIndex(Cura.ExtruderManager.activeExtruderIndex);
        }
    }

    //When the model of the extruders is rebuilt, the list of extruders is briefly emptied and rebuilt.
    //This causes the currentIndex of the tab to be in an invalid position which resets it to 0.
    //Therefore we need to change it back to what it was: The active extruder index.
    Connections
    {
        target: repeater.model
        onModelChanged:
        {
            tabBar.setCurrentIndex(Cura.ExtruderManager.activeExtruderIndex)
        }
    }

    //When switching back to the stage, make sure the active extruder is selected
    Component.onCompleted:
    {
        tabBar.setCurrentIndex(Cura.ExtruderManager.activeExtruderIndex)
    }
}
