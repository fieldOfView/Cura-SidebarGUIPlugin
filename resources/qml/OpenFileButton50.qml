// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Button
{
    id: openFileButton

    property var fileProviderModel: CuraApplication.getFileProviderModel()

    height: UM.Theme.getSize("button").height
    width: height
    x: -4 * UM.Theme.getSize("default_lining").width
    onClicked:
    {
        if (fileProviderModel.count <= 1)
        {
            Cura.Actions.open.trigger()
        }
        else
        {
            toggleContent()
        }
    }
    function toggleContent()
    {
        if (openFileButtonMenu.visible)
        {
            openFileButtonMenu.close()
        }
        else
        {
            openFileButtonMenu.open()
        }
    }

    hoverEnabled: true

    contentItem: Rectangle
    {
        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.getSize("thin_margin").width

        opacity: parent.enabled ? 1.0 : 0.2
        radius: Math.round(width * 0.5)

        color:
        {
            if(parent.hovered)
            {
                return UM.Theme.getColor("toolbar_button_hover")
            }
            return UM.Theme.getColor("toolbar_background")
        }

        UM.ColorImage
        {
            id: buttonIcon
            anchors.centerIn: parent
            width: height
            height: parent.height - UM.Theme.getSize("default_margin").height
            source: UM.Theme.getIcon("Folder", "medium")
            color: UM.Theme.getColor("icon")
        }

        UM.ColorImage
        {
            anchors
            {
                right: parent.right
                rightMargin: -4 * UM.Theme.getSize("default_lining").width
                bottom: parent.bottom
                bottomMargin: -2 * UM.Theme.getSize("default_lining").height
            }
            source: UM.Theme.getIcon("ChevronSingleDown")
            visible: fileProviderModel.count > 1
            width: UM.Theme.getSize("standard_arrow").width
            height: UM.Theme.getSize("standard_arrow").height
            color: UM.Theme.getColor("icon")
        }
    }

    background: Cura.RoundedRectangle
    {
        id: buttonBackground
        height: UM.Theme.getSize("button").height
        width: UM.Theme.getSize("button").width + UM.Theme.getSize("narrow_margin").width

        radius: UM.Theme.getSize("default_radius").width
        cornerSide: Cura.RoundedRectangle.Direction.Right

        color: UM.Theme.getColor("toolbar_background")
        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("lining")
    }

    Popup
    {
        id: openFileButtonMenu

        // Make the content aligned with the rest, using the property contentAlignment to decide whether is right or left.
        // In case of right alignment, the 3x padding is due to left, right and padding between the button & text.
        y: buttonBackground.height + 2 * UM.Theme.getSize("default_lining").height
        padding: UM.Theme.getSize("default_margin").width
        closePolicy: Popup.CloseOnPressOutsideParent

        background: Cura.RoundedRectangle
        {
            cornerSide: Cura.RoundedRectangle.Direction.All
            color: UM.Theme.getColor("action_button")
            border.width: UM.Theme.getSize("default_lining").width
            border.color: UM.Theme.getColor("lining")
            radius: UM.Theme.getSize("default_radius").width
        }

        contentItem: Item
        {
            id: popup

            Column
            {
                id: openProviderColumn

                //The column doesn't automatically listen to its children rect if the children change internally, so we need to explicitly update the size.
                onChildrenRectChanged:
                {
                    popup.height = childrenRect.height
                    popup.width = childrenRect.width
                }
                onPositioningComplete:
                {
                    popup.height = childrenRect.height
                    popup.width = childrenRect.width
                }

                Repeater
                {
                    model: openFileButton.fileProviderModel
                    delegate: Button
                    {
                        leftPadding: UM.Theme.getSize("default_margin").width
                        rightPadding: UM.Theme.getSize("default_margin").width
                        width: contentItem.width + leftPadding + rightPadding
                        height: UM.Theme.getSize("action_button").height
                        hoverEnabled: true

                        contentItem: Label
                        {
                            text: model.displayText
                            color: UM.Theme.getColor("text")
                            font: UM.Theme.getFont("medium")
                            renderType: Text.NativeRendering
                            verticalAlignment: Text.AlignVCenter

                            width: contentWidth
                            height: parent.height
                        }

                        onClicked:
                        {
                            if(model.index == 0) //The 0th element is the "From Disk" option, which should activate the open local file dialog.
                            {
                                Cura.Actions.open.trigger();
                            }
                            else
                            {
                                openFileButton.fileProviderModel.trigger(model.name);
                            }
                            openFileButton.toggleContent();
                        }

                        background: Rectangle
                        {
                            color: parent.hovered ? UM.Theme.getColor("action_button_hovered") : "transparent"
                            radius: UM.Theme.getSize("action_button_radius").width
                            width: popup.width
                        }
                    }
                }
            }
        }
    }
}
