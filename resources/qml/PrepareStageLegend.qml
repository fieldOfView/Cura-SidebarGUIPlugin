// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0 // for the linear gradient

import UM 1.0 as UM
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
        spacing: UM.Theme.getSize("layerview_row_spacing").height

        // For some reason the height/width of the column gets set to 0 if this is not set...
        Component.onCompleted:
        {
            height = implicitHeight
        }
        onActiveViewChanged:
        {
            height = undefined
        }

        property string activeView:
        {
            var viewString = UM.Controller.activeView + "";
            return viewString.substr(0, viewString.indexOf("("));
        }

        ExclusiveGroup { id: viewGroup }

        CheckBox
        {
            id: solidViewCheckBox
            checked: parent.activeView == "SolidView"
            onClicked:
            {
                if(checked && parent.activeView != "SolidView")
                {
                    UM.Controller.setActiveView("SolidView")
                }
            }
            text: catalog.i18nc("@label", "Normal view")
            style: UM.Theme.styles.checkbox
            width: parent.width
            exclusiveGroup: viewGroup
        }

        CheckBox
        {
            id: xrayViewCheckBox
            checked: parent.activeView == "XRayView"
            onClicked:
            {
                if(checked && parent.activeView != "XRayView")
                {
                    UM.Controller.setActiveView("XRayView")
                }
            }
            text: catalog.i18nc("@label", "X-Ray view")
            style: UM.Theme.styles.checkbox
            width: parent.width
            exclusiveGroup: viewGroup
        }

        Label
        {
            text: catalog.i18nc("@label", "Overhang")
            visible: parent.activeView == "SolidView"

            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            color: UM.Theme.getColor("setting_control_text")
            font: UM.Theme.getFont("default")
            renderType: Text.NativeRendering
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

        Label
        {
            text: catalog.i18nc("@label", "Normal geometry")
            visible: parent.activeView == "XRayView"

            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            color: UM.Theme.getColor("setting_control_text")
            font: UM.Theme.getFont("default")
            renderType: Text.NativeRendering
            Rectangle
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: UM.Theme.getSize("layerview_legend_size").width
                height: UM.Theme.getSize("layerview_legend_size").height

                border.width: UM.Theme.getSize("default_lining").width
                border.color: UM.Theme.getColor("lining")

                LinearGradient
                {
                    anchors.fill: parent
                    anchors.margins: UM.Theme.getSize("default_lining").width
                    start: Qt.point(0, 0)
                    end: Qt.point(width, 0)
                    gradient: Gradient
                    {
                        GradientStop { position: 0.0; color: UM.Theme.getColor("xray") }
                        GradientStop { position: 1.0; color: "white" }
                    }
                }
            }
        }

        Label
        {
            text: catalog.i18nc("@label", "Geometry error")
            visible: parent.activeView == "XRayView"

            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            color: UM.Theme.getColor("setting_control_text")
            font: UM.Theme.getFont("default")
            renderType: Text.NativeRendering
            Rectangle
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: UM.Theme.getSize("layerview_legend_size").width
                height: UM.Theme.getSize("layerview_legend_size").height

                color: UM.Theme.getColor("xray_error")

                border.width: UM.Theme.getSize("default_lining").width
                border.color: UM.Theme.getColor("lining")
            }
        }
    }
}
