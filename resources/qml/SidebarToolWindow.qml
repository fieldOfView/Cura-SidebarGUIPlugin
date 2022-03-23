import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Window 2.2

import UM 1.5 as UM
import Cura 1.1 as Cura

Window
{
    id: sidebarToolWindow
    title: catalog.i18nc("@title:window", "Print Settings")

    flags: Qt.Tool | Qt.WindowTitleHint | Qt.CustomizeWindowHint;

    function boolCheck(value) //Hack to ensure a good match between python and qml.
    {
        if(value == "True")
        {
            return true
        }else if(value == "False" || value == undefined)
        {
            return false
        }
        else
        {
            return value
        }
    }

    minimumWidth: UM.Theme.getSize("print_setup_widget").width
    maximumWidth: minimumWidth
    width: minimumWidth

    minimumHeight: Math.floor(1.5 * minimumWidth)
    height: UM.Preferences.getValue("sidebargui/settings_window_height") != 0 ? UM.Preferences.getValue("sidebargui/settings_window_height") : minimumHeight
    onHeightChanged: UM.Preferences.setValue("sidebargui/settings_window_height", height)

    x:
    {
        if (UM.Preferences.getValue("sidebargui/settings_window_left") != 65535 && boolCheck(UM.Preferences.getValue("general/restore_window_geometry")))
            return UM.Preferences.getValue("sidebargui/settings_window_left")
        return base.x + base.width - sidebarToolWindow.width + UM.Theme.getSize("wide_margin").width
    }
    y:
    {
        if (UM.Preferences.getValue("sidebargui/settings_window_top") != 65535 && boolCheck(UM.Preferences.getValue("general/restore_window_geometry")))
            return UM.Preferences.getValue("sidebargui/settings_window_top")
        return base.y + UM.Theme.getSize("wide_margin").width
    }
    onXChanged: UM.Preferences.setValue("sidebargui/settings_window_left", x)
    onYChanged: UM.Preferences.setValue("sidebargui/settings_window_top", y)

    property string tooltipText
    property var tooltipPosition
    function showTooltip()
    {
        toolTip.tooltipText = tooltipText
        toolTip.show()
    }

    function hideTooltip()
    {
        toolTip.hide()
    }

    visible: !settingsDocked && settingsVisible &&  (prepareStageActive || !preSlicedData)
    onVisibleChanged:
    {
        if (visible)
        {
            if(!Cura.SidebarGUIPlugin.checkRectangleOnScreen(Qt.rect(sidebarToolWindow.x, sidebarToolWindow.y, sidebarToolWindow.width, sidebarToolWindow.height)))
            {
                sidebarToolWindow.x = base.x + base.width - sidebarToolWindow.width + UM.Theme.getSize("wide_margin").width
                sidebarToolWindow.y = base.y + UM.Theme.getSize("wide_margin").width
            }
            printSetupWindow.children = [sidebarContents]
            printSetupTooltip.visible = false  // hide vestigial tooltip in main window
        }
        else
        {
            printSetupSidebar.children = [sidebarContents]
            printSetupTooltip.visible = true
        }
    }

    Item
    {
        id: printSetupWindow

        anchors.fill: parent

        UM.ToolTip
        {
            id: toolTip

            width: printSetupWindow.width - 2 * UM.Theme.getSize("default_margin").width
        }
    }
}