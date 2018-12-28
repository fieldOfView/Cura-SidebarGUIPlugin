// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

import UM 1.0 as UM
import Cura 1.0 as Cura


Cura.ExpandableComponent
{
    id: base

    contentHeaderTitle: catalog.i18nc("@label", "Legend")

    Connections
    {
        target: UM.Preferences
        onPreferenceChanged:
        {
        }
    }

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

        // For some reason the height/width of the column gets set to 0 if this is not set...
        Component.onCompleted:
        {
            height = implicitHeight
            width = UM.Theme.getSize("layerview_menu_size").width - 2 * UM.Theme.getSize("default_margin").width
        }

        Label
        {
            id: compatibilityModeLabel
            text: catalog.i18nc("@label", "TODO: add legend")
            font: UM.Theme.getFont("default")
            color: UM.Theme.getColor("text")
            height: UM.Theme.getSize("layerview_row").height
            width: parent.width
            renderType: Text.NativeRendering
        }

        Item  // Spacer
        {
            height: UM.Theme.getSize("narrow_margin").width
            width: parent.width
        }
    }
}
