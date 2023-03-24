// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Shapes 1.2

import UM 1.5 as UM
import Cura 1.0 as Cura

Cura.ExpandableComponent
{
    id: base

    contentHeaderTitle: catalog.i18nc("@label", "Legend")

    headerItem: Item
    {
        Label
        {
            text: catalog.i18nc("@label", "Legend")
            verticalAlignment: Text.AlignVCenter
            height: parent.height
            elide: Text.ElideRight
            font: UM.Theme.getFont("default")
            color: UM.Theme.getColor("text_medium")
            renderType: Text.NativeRendering
        }
    }

    contentItem: Column
    {
        id: viewSettings
        width: UM.Theme.getSize("layerview_menu_size").width - 2 * UM.Theme.getSize("default_margin").width
        height: implicitHeight
        spacing: UM.Theme.getSize("layerview_row_spacing").height

        onActiveViewChanged:
        {
            xrayViewCheckBox.checked = (activeView == "XRayView")
            xrayViewCheckBox.visible = (activeView != "FastView" && activeView != "SmartSliceView")
            switch(activeView)
            {
                case "FastView":
                    externalViewLabel.visible = true
                    externalViewLabel.text = catalog.i18nc("@label", "Fast View")
                    break;
                case "SmartSliceView":
                    externalViewLabel.visible = true
                    externalViewLabel.text = catalog.i18nc("@label", "Smart Slice")
                    break;
                default:
                    externalViewLabel.visible = false
                    break;
            }
        }

        property string activeView:
        {
            var viewString = UM.Controller.activeView + "";
            return viewString.substr(0, viewString.indexOf("("));
        }

        UM.CheckBox
        {
            id: xrayViewCheckBox
            checked: parent.activeView == "XRayView"
            visible: !externalViewLabel.visible
            onClicked:
            {
                if(checked && parent.activeView != "XRayView")
                {
                    UM.Controller.setActiveView("XRayView")
                }
                else if(! checked && parent.activeView != "SolidView")
                {
                    UM.Controller.setActiveView("SolidView")
                }
            }
            text: catalog.i18nc("@label", "X-Ray view")
            width: parent.width
        }

        UM.Label
        {
            id: externalViewLabel

            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            color: UM.Theme.getColor("setting_control_text")
        }

        Item
        {
            // mock item to compensate for compatibility mode label in simulation view
            visible: false
        }

        UM.Label
        {
            text: catalog.i18nc("@label", "Overhang")
            visible: parent.activeView == "SolidView"

            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            color: UM.Theme.getColor("setting_control_text")

            Rectangle
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: UM.Theme.getSize("layerview_legend_size").width
                height: UM.Theme.getSize("layerview_legend_size").height

                color: UM.Theme.getColor("model_overhang")

                border.width: UM.Theme.getSize("default_lining").width
                border.color: UM.Theme.getColor("lining")
            }
        }

        UM.Label
        {
            text: catalog.i18nc("@label", "Outside buildvolume")
            visible: parent.activeView == "SolidView"

            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            color: UM.Theme.getColor("setting_control_text")

            Rectangle
            {
                id: outsideBuildVolumeSwatch
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: UM.Theme.getSize("layerview_legend_size").width
                height: UM.Theme.getSize("layerview_legend_size").height
                clip: true

                border.width: UM.Theme.getSize("default_lining").width
                border.color: UM.Theme.getColor("lining")

                Rectangle
                {
                    anchors.fill: parent
                    scale: Math.sqrt(2)
                    rotation: 45
                    gradient: Gradient
                    {
                        GradientStop { position: 0.5; color: UM.Theme.getColor("model_unslicable") }
                        GradientStop { position: 0.5001; color: UM.Theme.getColor("model_unslicable_alt") }
                    }
                }
            }
        }

        UM.Label
        {
            text: catalog.i18nc("@label", "Normal geometry")
            visible: parent.activeView == "XRayView"

            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            color: UM.Theme.getColor("setting_control_text")

            Rectangle
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: UM.Theme.getSize("layerview_legend_size").width
                height: UM.Theme.getSize("layerview_legend_size").height

                border.width: UM.Theme.getSize("default_lining").width
                border.color: UM.Theme.getColor("lining")

                gradient: LinearGradient
                {
                    GradientStop { position: 0.0; color: UM.Theme.getColor("xray") }
                    GradientStop { position: 1.0; color: "white" }
                }
            }
        }

        UM.Label
        {
            text: catalog.i18nc("@label", "Geometry error")
            visible: parent.activeView == "XRayView"

            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            color: UM.Theme.getColor("setting_control_text")

            Rectangle
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: UM.Theme.getSize("layerview_legend_size").width
                height: UM.Theme.getSize("layerview_legend_size").height

                color: UM.Theme.getColor("error_area")

                border.width: UM.Theme.getSize("default_lining").width
                border.color: UM.Theme.getColor("lining")
            }
        }
    }
}
