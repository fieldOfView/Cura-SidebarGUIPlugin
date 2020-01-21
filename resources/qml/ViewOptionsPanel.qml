// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Rectangle
{
    id: viewOptionsPanel

    border.width: UM.Theme.getSize("default_lining").width
    border.color: UM.Theme.getColor("lining")
    color: UM.Theme.getColor("main_background")
    radius: UM.Theme.getSize("default_radius").width

    property string projectionType: UM.Preferences.getValue("general/camera_perspective_mode")

    Connections
    {
        target: UM.Preferences
        onPreferenceChanged:
        {
            if (preference !== "general/camera_perspective_mode")
            {
                return
            }
            projectionType = UM.Preferences.getValue("general/camera_perspective_mode")
        }
    }


    Column
    {
        id: viewOptions
        spacing: UM.Theme.getSize("thin_margin").height
        children:
        [
            viewPanelOrientationControls,
            viewMenuComponent.item.contentItem
        ]
        anchors.top: parent.top
        anchors.topMargin: UM.Theme.getSize("default_margin").height
    }

    Item {
        // hidden items
        visible: false

        Row
        {
            id: viewPanelOrientationControls

            spacing: UM.Theme.getSize("narrow_margin").width

            anchors.left: parent.left
            anchors.leftMargin: UM.Theme.getSize("default_margin").width - 2 * UM.Theme.getSize("default_lining").width

            Cura.ViewOrientationControls {}

            UM.SimpleButton
            {
                id: projectionToggle
                iconSource:
                {
                    if(viewOptionsPanel.projectionType == "orthographic")
                    {
                        return "../icons/view_perspective.svg"
                    }
                    else
                    {
                        return "../icons/view_orthographic.svg"
                    }
                }
                onClicked:
                {
                    if(viewOptionsPanel.projectionType == "orthographic")
                    {
                        UM.Preferences.setValue("general/camera_perspective_mode", "perspective")
                    }
                    else
                    {
                        UM.Preferences.setValue("general/camera_perspective_mode", "orthographic")
                    }
                }

                width: UM.Theme.getSize("small_button").width
                height: UM.Theme.getSize("small_button").height
                hoverColor: UM.Theme.getColor("small_button_text_hover")
                color: UM.Theme.getColor("small_button_text")
                iconMargin: UM.Theme.getSize("thick_lining").width

                UM.TooltipArea
                {
                    anchors.fill: parent
                    text:
                    {
                        if(viewOptionsPanel.projectionType == "orthographic")
                        {
                            return catalog.i18nc("@info:tooltip", "Perspective View")
                        }
                        else
                        {
                            return catalog.i18nc("@info:tooltip", "Orthographic View")
                        }
                    }

                    acceptedButtons: Qt.NoButton
                }
            }

        }

        Loader
        {
            id: viewMenuComponent
            height: parent.height
            width: UM.Theme.getSize("layerview_menu_size").width
            source:
            {
                if(
                    UM.Controller.activeView != null &&
                    UM.Controller.activeView.stageMenuComponent != null &&
                    !UM.Controller.activeView.stageMenuComponent.toString().endsWith("EmptyViewMenuComponent.qml")
                )
                {
                    return UM.Controller.activeView.stageMenuComponent;
                }
                return "PrepareStageLegend.qml";
            }
        }
    }

    height: viewOptions.height + 2 * UM.Theme.getSize("default_margin").height
    width: UM.Theme.getSize("layerview_menu_size").width
}
