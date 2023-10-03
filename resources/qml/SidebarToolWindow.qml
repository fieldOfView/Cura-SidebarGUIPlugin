import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Window 2.2

import UM 1.3 as UM
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

    property string toolTipText
    property int toolTipY
    function showTooltip()
    {
        toolTip.text = toolTipText
        toolTip.target = Qt.point(4 * UM.Theme.getSize("default_margin").width, toolTipY)
        if (toolTipY < (sidebarToolWindow.height / 2))
        {
            toolTip.y = toolTipY + 2 * UM.Theme.getSize("default_margin").height
            toolTip.anchors.bottom = undefined
        }
        else
        {
            toolTip.y = toolTipY - toolTip.height - 1 * UM.Theme.getSize("default_margin").height
            toolTip.anchors.top = undefined
        }
        toolTip.opacity = 1
    }

    function hideTooltip()
    {
        toolTip.opacity = 0
    }

    visible: !settingsDocked && settingsVisible &&  (prepareStageActive || !preSlicedData)
    onVisibleChanged:
    {
        if (visible)
        {
            var sidebar_rect = Qt.rect(sidebarToolWindow.x, sidebarToolWindow.y, sidebarToolWindow.width, sidebarToolWindow.height)
            if(!SidebarGUIPlugin.checkRectangleOnScreen(sidebar_rect))
            {
                sidebarToolWindow.x = base.x + base.width - sidebarToolWindow.width + UM.Theme.getSize("wide_margin").width
                sidebarToolWindow.y = base.y + UM.Theme.getSize("wide_margin").width
            }
            printSetupWindow.children = [sidebarContents, toolTip]
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
    }

    Item
    {
        visible: false

        UM.PointingRectangle
        {
            id: toolTip

            width: printSetupWindow.width - 2 * UM.Theme.getSize("default_margin").width - UM.Theme.getSize("thick_margin").width
            x: UM.Theme.getSize("thick_margin").width
            height: Math.min(label.height + 2 * UM.Theme.getSize("default_margin").height, 400)

            property alias text: label.text
            color: UM.Theme.getColor("tooltip")
            arrowSize: UM.Theme.getSize("default_arrow").width

            opacity: 0
            // This should be disabled when invisible, otherwise it will catch mouse events.
            visible: opacity > 0
            enabled: visible

            Behavior on opacity
            {
                NumberAnimation { duration: 200; }
            }

            Label
            {
                id: label
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: UM.Theme.getSize("tooltip_margins").width
                textFormat: Text.RichText
                color: UM.Theme.getColor("tooltip_text")
                font: UM.Theme.getFont("default")
                wrapMode: Text.Wrap
                renderType: Qt.platform.os == "osx" ? Text.QtRendering : Text.NativeRendering
            }
        }
    }
}