// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Item
{
    width: parent.width
    height: UM.Theme.getSize("setting_control").height + UM.Theme.getSize("default_margin").height

    anchors
    {
        top: parent.top
        left: parent.left
        leftMargin: parent.padding
        right: parent.right
        rightMargin: parent.padding
    }

    NoIntentIcon
    {
        id: noIntentIcon
        affected_extruders: Cura.MachineManager.extruderPositionsWithNonActiveIntent
        intent_type: Cura.MachineManager.activeIntentCategory
        anchors.right: modeToggleSwitch.left
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
        anchors.verticalCenter: intentSelection.verticalCenter
        width: height
        height: UM.Theme.getSize("default_margin").height +  2 * UM.Theme.getSize("default_lining").height
        visible: affected_extruders.length && intentSelection.visible
    }

    Button
    {
        id: intentSelection
        onClicked: menu.opened ? menu.close() : menu.open()

        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.getSize("narrow_margin").width + UM.Theme.getSize("default_margin").width
        anchors.right: noIntentIcon.left
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
        height: textLabel.contentHeight + 2 * UM.Theme.getSize("narrow_margin").height
        hoverEnabled: true
        visible: printSetupSelector.contentItem.currentModeIndex == Cura.PrintSetupSelectorContents.Mode.Custom

        baselineOffset: 0 // If we don't do this, there is a binding loop. WHich is a bit weird, since we override the contentItem anyway...

        contentItem: RowLayout
        {
            spacing: 0
            anchors.left: parent.left
            anchors.right: customisedSettings.left
            anchors.leftMargin: UM.Theme.getSize("default_margin").width

            Label
            {
                id: textLabel
                text: Cura.MachineManager.activeQualityDisplayNameMap["main"]
                font: UM.Theme.getFont("default")
                color: UM.Theme.getColor("text")
                Layout.margins: 0
                Layout.maximumWidth: Math.floor(parent.width * 0.7)  // Always leave >= 30% for the rest of the row.
                height: contentHeight
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
                elide: Text.ElideRight
            }

            Label
            {
                text: activeQualityDetailText()
                font: UM.Theme.getFont("default")
                color: UM.Theme.getColor("text_detail")
                Layout.margins: 0
                Layout.fillWidth: true

                height: contentHeight
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
                elide: Text.ElideRight

                function activeQualityDetailText()
                {
                    var resultMap = Cura.MachineManager.activeQualityDisplayNameMap
                    var resultSuffix = resultMap["suffix"]
                    var result = ""

                    if (Cura.MachineManager.isActiveQualityExperimental)
                    {
                        resultSuffix += " (Experimental)"
                    }

                    if (Cura.MachineManager.isActiveQualitySupported)
                    {
                        if (Cura.MachineManager.activeQualityLayerHeight > 0)
                        {
                            if (resultSuffix)
                            {
                                result += " - " + resultSuffix
                            }
                            result += " - "
                            result += Cura.MachineManager.activeQualityLayerHeight + "mm"
                        }
                    }

                    return result
                }
            }
        }

        background: Rectangle
        {
            id: backgroundItem
            border.color: intentSelection.hovered ? UM.Theme.getColor("setting_control_border_highlight") : UM.Theme.getColor("setting_control_border")
            border.width: UM.Theme.getSize("default_lining").width
            radius: UM.Theme.getSize("default_radius").width
            color: UM.Theme.getColor("main_background")
        }

        UM.SimpleButton
        {
            id: customisedSettings

            visible: Cura.MachineManager.hasUserSettings
            width: UM.Theme.getSize("print_setup_icon").width
            height: UM.Theme.getSize("print_setup_icon").height

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: downArrow.left
            anchors.rightMargin: UM.Theme.getSize("default_margin").width

            color: hovered ? UM.Theme.getColor("setting_control_button_hover") : UM.Theme.getColor("setting_control_button");
            iconSource:
            {
                if(isLE410)
                {
                    UM.Theme.getIcon("star")
                }
                return UM.Theme.getIcon("StarFilled")
            }

            onClicked:
            {
                forceActiveFocus();
                Cura.Actions.manageProfiles.trigger()
            }
            onEntered:
            {
                var content = catalog.i18nc("@tooltip", "Some setting/override values are different from the values stored in the profile.\n\nClick to open the profile manager.")
                base.showTooltip(intent, Qt.point(-UM.Theme.getSize("default_margin").width, 0), content)
            }
            onExited: base.hideTooltip()
        }
        UM.RecolorImage
        {
            id: downArrow

            source: UM.Theme.getIcon("arrow_bottom")
            width: UM.Theme.getSize("standard_arrow").width
            height: UM.Theme.getSize("standard_arrow").height

            anchors
            {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: UM.Theme.getSize("default_margin").width
            }

            color: UM.Theme.getColor("setting_control_button")
        }
    }

    Cura.QualitiesWithIntentMenu
    {
        id: menu
        y: intentSelection.y + intentSelection.height
        x: intentSelection.x
        width: intentSelection.width
    }

    ModeToggleSwitch
    {
        id: modeToggleSwitch
        anchors.right: dockButton.left
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
    }

    UM.SimpleButton
    {
        id: dockButton
        anchors
        {
            verticalCenter: collapseButton.verticalCenter

            right: collapseButton.left
            rightMargin: UM.Theme.getSize("default_margin").width
        }
        iconSource: settingsDocked ? "../icons/settings_undock.svg" : "../icons/settings_dock.svg"
        width: UM.Theme.getSize("default_arrow").width + UM.Theme.getSize("default_lining").width
        height: width
        color: UM.Theme.getColor("small_button_text")

        onClicked:
        {
            UM.Preferences.setValue("sidebargui/docked_sidebar", !UM.Preferences.getValue("sidebargui/docked_sidebar"))
            stageMenu.settingsDocked = UM.Preferences.getValue("sidebargui/docked_sidebar")
        }
    }

    UM.SimpleButton
    {
        id: collapseButton
        anchors
        {
            top: parent.top
            topMargin: UM.Theme.getSize("default_margin").width

            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }
        iconSource: UM.Theme.getIcon("cross1")
        width: UM.Theme.getSize("default_arrow").width + UM.Theme.getSize("default_lining").width
        height: width
        color: UM.Theme.getColor("small_button_text")

        onClicked:
        {
            UM.Preferences.setValue("view/settings_visible", false)
            stageMenu.settingsVisible = false
        }
    }
}
