// Copyright (c) 2019 fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.4
import QtQuick.Controls 1.2

import UM 1.0 as UM

Loader
{
    id: loader
    source: UM.Controller.activeView != null && UM.Controller.activeView.mainComponent != null ? UM.Controller.activeView.mainComponent : ""

    onLoaded:
    {
        var viewString = UM.Controller.activeView + "";
        var activeView = viewString.substr(0, viewString.indexOf("("));
        if(activeView == "SimulationView")
        {
            var pathSlider = item.children[0];
            pathSlider.anchors.horizontalCenter = undefined;
            pathSlider.anchors.right = pathSlider.parent.right;
            pathSlider.anchors.rightMargin = UM.Theme.getSize("print_setup_widget").width + UM.Theme.getSize("default_margin").width;

            var layerSlider = item.children[2];
            layerSlider.anchors.right = pathSlider.right;
            layerSlider.anchors.rightMargin = 0;
            layerSlider.anchors.verticalCenter = undefined;
            layerSlider.anchors.top = undefined;
            layerSlider.anchors.bottom = pathSlider.top;
            layerSlider.anchors.bottomMargin = UM.Theme.getSize("default_margin").height;
            layerSlider.height = UM.Theme.getSize("slider_layerview_size").height - (pathSlider.height + UM.Theme.getSize("default_margin").height);
        }
    }
}