// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.5 as UM
import Cura 1.1 as Cura

TabRow
{
    id: tabBar

    property var extrudersModel: CuraApplication.getExtrudersModel()
    property bool hasMaterials: (Cura.MachineManager.activeMachine != null) ? Cura.MachineManager.activeMachine.hasMaterials : false
    property bool hasVariants: (Cura.MachineManager.activeMachine != null) ? Cura.MachineManager.activeMachine.hasVariants : false
    visible: hasMaterials || hasVariants
    width: parent.width
    height: UM.Theme.getSize("extruder_icon").height + UM.Theme.getSize("narrow_margin").height

    property int extrudersCount: extrudersModel.count

    Repeater
    {
        id: repeater
        model: extrudersModel
        delegate: TabRowButton
        {
            width: Math.floor((tabBar.width - (extrudersCount - 1) * UM.Theme.getSize("narrow_margin").width) / extrudersCount)
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
                UM.Label
                {
                    id: typeAndBrandNameLabel

                    text: model.material_brand + " " + model.material
                    elide: Text.ElideRight
                    font: UM.Theme.getFont("default")
                    color: UM.Theme.getColor("text")
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
                UM.Label
                {
                    id: variantLabel

                    text: model.variant
                    elide: Text.ElideRight
                    font: UM.Theme.getFont("default_bold")
                    color: UM.Theme.getColor("text")
                    wrapMode: Text.NoWrap
                    visible: hasVariants

                    anchors
                    {
                        left: extruderIcon.right
                        leftMargin: UM.Theme.getSize("default_margin").width
                        top: typeAndBrandNameLabel.bottom
                    }
                }

                UM.StatusIcon
                {
                    id: configurationWarning

                    visible: status != UM.StatusIcon.Status.NEUTRAL
                    height: visible ? UM.Theme.getSize("message_type_icon").height: 0
                    width: visible ? UM.Theme.getSize("message_type_icon").height : 0

                    property var extruderStack:
                    {
                        return (Cura.MachineManager.activeMachine != null) ? Cura.MachineManager.activeMachine.extruderList[model.index] : undefined;
                    }

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    status:
                    {
                        if (model.enabled && (tabBar.hasMaterials || tabBar.hasVariants))
                        {
                            if (extruderStack != undefined && Cura.ContainerManager.getContainerMetaDataEntry(extruderStack.material.id, "compatible") != "True")
                            {
                                return UM.StatusIcon.Status.ERROR
                            }
                            if (!SidebarGUIPlugin.getExtruderHasQualityForMaterial(extruderStack))
                            {
                                return UM.StatusIcon.Status.WARNING
                            }
                        }
                        return UM.StatusIcon.Status.NEUTRAL
                    }

                    MouseArea // Connection status tooltip hover area
                    {
                        id: tooltipHoverArea
                        anchors.fill: parent
                        hoverEnabled: tooltip.text != ""
                        acceptedButtons: Qt.NoButton // react to hover only, don't steal clicks

                        onEntered: tooltip.show()
                        onExited: tooltip.hide()
                    }

                    UM.ToolTip
                    {
                        id: tooltip
                        x: 0
                        y: parent.height + UM.Theme.getSize("default_margin").height
                        width: UM.Theme.getSize("tooltip").width
                        targetPoint: Qt.point(Math.round(extruderIcon.width / 2), 0)
                        text:
                        {
                            if (configurationWarning.status == UM.StatusIcon.Status.ERROR)
                            {
                                return catalog.i18nc("@tooltip", "The configuration of this extruder is not allowed, and prohibits slicing.")
                            }
                            if (configurationWarning.status == UM.StatusIcon.Status.WARNING)
                            {
                                return catalog.i18nc("@tooltip", "There are no profiles matching the configuration of this extruder.")
                            }
                            return ""
                        }
                    }
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
        function onActiveExtruderChanged()
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
        function onModelChanged()
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
