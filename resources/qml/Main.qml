// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.4
import QtQuick.Controls 1.2

import UM 1.0 as UM

Loader
{
    id: legend

    source: UM.Controller.activeView != null && UM.Controller.activeView.mainComponent != null ? UM.Controller.activeView.mainComponent : ""
}