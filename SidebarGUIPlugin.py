# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import os.path
from UM.Application import Application
from UM.Extension import Extension
from UM.Logger import Logger

try:
    from cura.ApplicationMetadata import CuraSDKVersion
except ImportError: # Cura <= 3.6
    CuraSDKVersion = "6.0.0"
if CuraSDKVersion >= "8.0.0":
    from PyQt6.QtCore import QTimer
else:
    from PyQt5.QtCore import QTimer

from .SidebarGUIProxy import SidebarGUIProxy


class SidebarGUIPlugin(Extension):
    def __init__(self):
        super().__init__()

        self._prepare_stage_view_id = "SolidView"  # can be "SolidView" or "XRayView"

        Application.getInstance().pluginsLoaded.connect(self._onPluginsLoaded)
        preferences = Application.getInstance().getPreferences()
        preferences.addPreference("sidebargui/expand_extruder_configuration", False)
        preferences.addPreference("sidebargui/expand_legend", True)
        preferences.addPreference("sidebargui/docked_sidebar", True)
        preferences.addPreference("sidebargui/settings_window_left", 65535)
        preferences.addPreference("sidebargui/settings_window_top", 65535)
        preferences.addPreference("sidebargui/settings_window_height", 0)

        self._controller = Application.getInstance().getController()
        self._controller.activeStageChanged.connect(self._onStageChanged)
        self._controller.activeViewChanged.connect(self._onViewChanged)

        self._proxy = SidebarGUIProxy()

    def _onPluginsLoaded(self):
        # delayed connection to engineCreatedSignal to force this plugin to receive that signal
        # AFTER the original stages are created
        Application.getInstance().engineCreatedSignal.connect(self._onEngineCreated)

    def _onEngineCreated(self):
        Logger.log("d", "Registering replacement stages")

        engine = Application.getInstance()._qml_engine
        engine.rootContext().setContextProperty("SidebarGUIPlugin", self._proxy)

        sidebar_component_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "resources",
            "qml",
            "SidebarStageMenu.qml",
        )
        main_component_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "resources",
            "qml",
            "StageMain.qml",
        )
        monitor_menu_component_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "resources",
            "qml",
            "MonitorStageMenu.qml",
        )

        prepare_stage = self._controller.getStage("PrepareStage")
        prepare_stage.addDisplayComponent("menu", sidebar_component_path)
        prepare_stage.addDisplayComponent("main", main_component_path)

        preview_stage = self._controller.getStage("PreviewStage")
        preview_stage.addDisplayComponent("menu", sidebar_component_path)
        preview_stage.addDisplayComponent("main", main_component_path)

        # SmartSlicePlugin stage is provided by the SmartSlicePlugin plugin
        if "SmartSlicePlugin" in self._controller.getAllStages():
            smartslice_stage = self._controller.getStage("SmartSlicePlugin")
            smartslice_stage.addDisplayComponent("menu", sidebar_component_path)
            smartslice_stage.addDisplayComponent("main", main_component_path)

        monitor_stage = self._controller.getStage("MonitorStage")
        monitor_stage.addDisplayComponent("menu", monitor_menu_component_path)

    def _onStageChanged(self):
        active_stage_id = self._controller.getActiveStage().getPluginId()
        active_view = self._controller.getActiveView()

        # Don't change view if PaintTool is active
        if active_view and active_view.getPluginId() == "PaintTool":
            return

        view_id = ""

        if active_stage_id == "PrepareStage":
            view_id = self._prepare_stage_view_id
        elif active_stage_id == "PreviewStage":
            view_id = "SimulationView"

        if view_id and (
            self._controller.getActiveView() is None
            or view_id != self._controller.getActiveView().getPluginId()
        ):
            self._controller.setActiveView(view_id)

    def _onViewChanged(self):
        active_stage = self._controller.getActiveStage()
        active_view = self._controller.getActiveView()

        if not active_stage or not active_view:
            return

        active_stage_id = active_stage.getPluginId()
        active_view_id = active_view.getPluginId()

        # Force machine settings update when PaintTool is activated to fix rendering issue
        if active_view_id == "PaintTool":
            QTimer.singleShot(0, lambda: Application.getInstance().getMachineManager().forceUpdateAllSettings())

        if (
            active_stage_id == "SmartSlicePlugin"
        ):  # SmartSlicePlugin view is provided by the SmartSlicePlugin plugin
            return

        if active_stage_id == "PrepareStage":
            if active_view_id not in ["SolidView", "XRayView", "PaintTool"]:
                self._controller.setActiveView("SolidView")
                return
            if active_view_id in ["SolidView", "XRayView"]:
                self._prepare_stage_view_id = active_view_id
        elif active_stage_id == "MonitorStage":
            return
        elif active_stage_id == "PreviewStage":
            # Ensure SimulationView is active when in PreviewStage
            if active_view_id != "SimulationView":
                self._controller.setActiveView("SimulationView")
            return

        if active_view_id in [
            "SimulationView",
            "FastView",
        ]:  # FastView is provided by the RAWMouse plugin
            if active_stage_id != "PreviewStage":
                self._controller.setActiveStage("PreviewStage")
        elif active_view_id not in ["PaintTool"]:
            if active_stage_id != "PrepareStage":
                self._controller.setActiveStage("PrepareStage")
