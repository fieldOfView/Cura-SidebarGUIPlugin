// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

UM.TabRow
{
    id: tabBar

    property var extrudersModel: CuraApplication.getExtrudersModel()

    visible: Cura.MachineManager.hasMaterials || Cura.MachineManager.hasVariants
    width: parent.width

    Repeater
    {
        id: repeater
        model: extrudersModel
        delegate: UM.TabRowButton
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

                // Label that shows the name of the variant
                Label
                {
                    id: variantLabel

                    text: model.variant
                    elide: Text.ElideRight
                    font: UM.Theme.getFont("medium")
                    color: UM.Theme.getColor("text")
                    renderType: Text.NativeRendering

                    visible: Cura.MachineManager.hasVariants

                    anchors
                    {
                        left: extruderIcon.right
                        leftMargin: UM.Theme.getSize("default_margin").width
                        verticalCenter: parent.verticalCenter
                    }
                }

                // Label for the brand of the material
                Label
                {
                    id: brandNameLabel

                    text: model.material_brand
                    elide: Text.ElideRight
                    font: UM.Theme.getFont("default")
                    color: UM.Theme.getColor("text_inactive")
                    renderType: Text.NativeRendering

                    visible: Cura.MachineManager.hasMaterials

                    anchors
                    {
                        left: variantLabel.visible ? variantLabel.right : extruderIcon.right
                        leftMargin: UM.Theme.getSize("default_margin").width
                        right: configurationWarning.left
                        rightMargin: UM.Theme.getSize("default_margin").width
                    }
                }

                // Label that shows the name of the material
                Label
                {
                    text: model.material
                    elide: Text.ElideRight
                    font: UM.Theme.getFont("medium")
                    color: UM.Theme.getColor("text")
                    renderType: Text.NativeRendering

                    visible: Cura.MachineManager.hasMaterials

                    anchors
                    {
                        left: variantLabel.visible ? variantLabel.right : extruderIcon.right
                        leftMargin: UM.Theme.getSize("default_margin").width
                        right: configurationWarning.left
                        rightMargin: UM.Theme.getSize("default_margin").width
                        top: brandNameLabel.bottom
                    }
                }

                UM.RecolorImage
                {
                    id: configurationWarning

                    property var extruderStack: Cura.MachineManager.getExtruder(model.index)
                    property bool valueWarning: !Cura.SidebarGUIPlugin.getExtruderHasQualityForMaterial(extruderStack)
                    property bool valueError: Cura.ContainerManager.getContainerMetaDataEntry(extruderStack.material.id, "compatible", "") != "True"

                    visible: valueWarning || valueError

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
}
