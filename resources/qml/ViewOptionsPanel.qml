// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Rectangle
{
    border.width: UM.Theme.getSize("default_lining").width
    border.color: UM.Theme.getColor("lining")
    color: UM.Theme.getColor("main_background")
    radius: UM.Theme.getSize("default_radius").width

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

        Cura.ViewOrientationControls {
            id: viewPanelOrientationControls
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Loader
        {
            id: viewMenuComponent
            height: parent.height
            width: UM.Theme.getSize("layerview_menu_size").width
            source:
            {
                if(UM.Controller.activeView != null && UM.Controller.activeView.stageMenuComponent != null)
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
