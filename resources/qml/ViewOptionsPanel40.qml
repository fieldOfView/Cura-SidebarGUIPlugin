// Copyright (c) 2023 Aldo Hoeben / fieldOfView
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
    clip: true

    Behavior on height { NumberAnimation { duration: 100 } }

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
            legendHeader,
            legendItems
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

            Cura.ViewOrientationControls
            {
                Component.onCompleted:
                {
                    if(!isLE410)
                    {
                        for(var child_nr in children)
                        {
                            children[child_nr].iconMargin = 3 * UM.Theme.getSize("default_lining").width
                        }
                    }
                }
            }

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
                return "PrepareStageLegend40.qml";
            }

            onLoaded:
            {
                legendHeaderItem.children = [
                    viewMenuComponent.item.contentItem.children[0],
                    viewMenuComponent.item.contentItem.children[1]
                ]
                legendItems.children = [
                    viewMenuComponent.item.contentItem
                ]
            }
        }

        Item
        {
            id: legendHeader
            width: parent.width
            height: childrenRect.height

            anchors.left: parent.left
            anchors.leftMargin: UM.Theme.getSize("default_margin").width

            Item {
                id: legendHeaderItem
                anchors
                {
                    left: parent.left
                    right: legendCollapseButton.left
                    rightMargin: UM.Theme.getSize("default_margin").width
                }
                height: childrenRect.height

                // populated by viewMenuComponent
            }

            UM.SimpleButton
            {
                id: legendCollapseButton
                anchors
                {
                    right: parent.right
                    rightMargin: UM.Theme.getSize("narrow_margin").width
                    verticalCenter: legendHeaderItem.verticalCenter
                }
                iconSource: legendItems.visible ? UM.Theme.getIcon("arrow_bottom") : UM.Theme.getIcon("arrow_left")
                width: UM.Theme.getSize("standard_arrow").width
                height: UM.Theme.getSize("standard_arrow").height
                color: UM.Theme.getColor("setting_category_text")

                onClicked:
                {
                    legendItems.visible = !legendItems.visible;
                    UM.Preferences.setValue("sidebargui/expand_legend", legendItems.visible);
                }
            }
        }

        Column
        {
            id: legendItems
            visible: UM.Preferences.getValue("sidebargui/expand_legend")

            // populated by viewMenuComponent
        }
    }

    height: viewOptions.height + 2 * UM.Theme.getSize("default_margin").height
    width: UM.Theme.getSize("layerview_menu_size").width
}
