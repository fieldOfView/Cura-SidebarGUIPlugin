// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Cura.RoundedRectangle
{
    id: actionRow

    anchors.bottom: bottomRight.bottom
    anchors.right: bottomRight.right

    border.width: UM.Theme.getSize("default_lining").width
    border.color: UM.Theme.getColor("lining")
    color: UM.Theme.getColor("main_background")

    cornerSide: Cura.RoundedRectangle.Direction.Left
    radius: UM.Theme.getSize("default_radius").width

    Cura.ActionPanelWidget
    {
        id: actionPanelWidget
        visible: CuraApplication.platformActivity
        width: parent.width
        anchors.bottom: parent.bottom

        property string activeViewId:
        {
            var viewString = UM.Controller.activeView + "";
            return viewString.substr(0, viewString.indexOf("("));
        }

        onActiveViewIdChanged: updateHasPreviewButton();

        function updateHasPreviewButton()
        {
            var actionPanelRect = actionPanelWidget.children[0];

            if(actionPanelRect.outputAvailable)
            {
                actionPanelRect.children[0].item.hasPreviewButton = (actionPanelWidget.activeViewId != "SimulationView");
            }
        }

        Connections
        {
            target: actionPanelWidget.children[0].children[0]
            onLoaded:
            {
                actionPanelWidget.updateHasPreviewButton();
            }
        }

        Component.onCompleted:
        {
            var actionPanelRect = actionPanelWidget.children[0];
            var actionPanelAdditionals = actionPanelWidget.children[1];

            actionPanelRect.border.width = 0;
            actionPanelRect.color = "transparent";

            actionPanelAdditionals.anchors.right = undefined;
            actionPanelAdditionals.anchors.left = actionPanelAdditionals.parent.left;
            actionPanelAdditionals.anchors.leftMargin = UM.Theme.getSize("thick_margin").width;
            actionPanelAdditionals.anchors.bottomMargin = UM.Theme.getSize("thick_margin").height * 2 - UM.Theme.getSize("default_lining").height * 3;

            actionPanelRect.width = undefined;
            actionPanelRect.anchors.left = actionPanelAdditionals.right;
            actionPanelRect.anchors.leftMargin = -UM.Theme.getSize("default_margin").width;
            actionPanelRect.anchors.right = actionPanelRect.parent.right;
        }
    }

    width: UM.Theme.getSize("print_setup_widget").width
    height: CuraApplication.platformActivity ? actionPanelWidget.height : 0
}
