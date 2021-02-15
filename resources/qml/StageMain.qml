// Copyright (c) 2020 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.4
import QtQuick.Controls 1.2

import UM 1.0 as UM

Loader
{
    id: loader
    source: UM.Controller.activeView != null && UM.Controller.activeView.mainComponent != null ? UM.Controller.activeView.mainComponent : ""

    property bool preSlicedData: PrintInformation !== null && PrintInformation.preSliced
    property bool settingsVisible: UM.Preferences.getValue("view/settings_visible")
    property bool settingsDocked: UM.Preferences.getValue("sidebargui/docked_sidebar")
    property bool sidebarVisible: settingsVisible && !preSlicedData && settingsDocked

    onLoaded:
    {
        var viewString = UM.Controller.activeView + "";
        var activeView = viewString.substr(0, viewString.indexOf("("));
        if(activeView == "SimulationView")
        {
            var sidebarFooter = stageMenu.item.children[5];

            var pathSlider = item.children[0];
            pathSlider.anchors.horizontalCenter = undefined;
            pathSlider.anchors.right = pathSlider.parent.right;
            pathSlider.anchors.rightMargin = Qt.binding(function()
            {
                if(sidebarVisible)
                    return UM.Theme.getSize("print_setup_widget").width + UM.Theme.getSize("default_margin").width;
                else
                    return UM.Theme.getSize("default_margin").width;
            });
            pathSlider.anchors.bottomMargin = Qt.binding(function()
            {
                if(sidebarVisible)
                    return UM.Theme.getSize("default_margin").height;
                else
                    return sidebarFooter.height + UM.Theme.getSize("default_margin").height
            });

            var layerSlider = item.children[2];
            layerSlider.anchors.right = pathSlider.right;
            layerSlider.anchors.rightMargin = 0;
            layerSlider.anchors.verticalCenter = undefined;
            layerSlider.anchors.top = undefined;
            layerSlider.anchors.bottom = pathSlider.top;
            layerSlider.anchors.bottomMargin = UM.Theme.getSize("default_margin").height;
            layerSlider.height = Qt.binding(function()
            {
                var unavailableHeight = (stageMenu.item.children[2].height + pathSlider.height + 5 * UM.Theme.getSize("default_margin").height);
                if(!sidebarVisible)
                    unavailableHeight = (sidebarFooter.height + stageMenu.item.children[3].height + pathSlider.height + 3 * UM.Theme.getSize("default_margin").height)

                return Math.min(
                        UM.Theme.getSize("slider_layerview_size").height,
                        contentItem.height - unavailableHeight
                    );
            })
        }
    }

    Connections
    {
        target: UM.Preferences
        onPreferenceChanged:
        {
            switch (preference)
            {
                case "view/settings_visible":
                    settingsVisible = UM.Preferences.getValue("view/settings_visible")
                    base.onWidthChanged(base.width)
                    break
                case "sidebargui/docked_sidebar":
                    settingsDocked = UM.Preferences.getValue("sidebargui/docked_sidebar")
                    break
            }
        }
    }
}