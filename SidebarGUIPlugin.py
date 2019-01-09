# Copyright (c) 2019 fieldOfView
# The SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import os.path
from UM.Application import Application
from UM.Extension import Extension
from UM.Resources import Resources

from PyQt5.QtCore import QUrl
from PyQt5.QtQml import qmlRegisterSingletonType

from .SidebarGUIProxy import SidebarGUIProxy


class SidebarGUIPlugin(Extension):

    def __init__(self):
        super().__init__()

        self._prepare_stage_view_id = "SolidView"

        Application.getInstance().engineCreatedSignal.connect(self._onEngineCreated)

        self._controller = Application.getInstance().getController()
        self._controller.activeStageChanged.connect(self._onStageChanged)
        self._controller.activeViewChanged.connect(self._onViewChanged)

        self._proxy = SidebarGUIProxy()

    def _onEngineCreated(self):
        engine = Application.getInstance()._qml_engine
        qmlRegisterSingletonType(SidebarGUIProxy, "Cura", 1, 0, "SidebarGUIPlugin", self.getProxy)

        sidebar_component_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "resources", "qml", "SidebarStageMenu.qml")
        main_component_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "resources", "qml", "StageMain.qml")
        monitor_menu_component_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "resources", "qml", "MonitorStageMenu.qml")

        prepare_stage = self._controller.getStage("PrepareStage")
        prepare_stage.addDisplayComponent("menu", sidebar_component_path)
        prepare_stage.addDisplayComponent("main", main_component_path)

        preview_stage = self._controller.getStage("PreviewStage")
        preview_stage.addDisplayComponent("menu", sidebar_component_path)
        preview_stage.addDisplayComponent("main", main_component_path)

        monitor_stage = self._controller.getStage("MonitorStage")
        monitor_stage.addDisplayComponent("menu", monitor_menu_component_path)


    def _onStageChanged(self):
        active_stage_id = self._controller.getActiveStage().getPluginId()
        view_id = ""

        if active_stage_id == "PrepareStage":
            view_id = self._prepare_stage_view_id
        elif active_stage_id == "PreviewStage":
            view_id = "SimulationView"

        if view_id and (self._controller.getActiveView() is None or view_id != self._controller.getActiveView().getPluginId()):
            self._controller.setActiveView(view_id)


    def _onViewChanged(self):
        active_stage_id = self._controller.getActiveStage().getPluginId()
        active_view_id = self._controller.getActiveView().getPluginId()

        if active_stage_id == "PrepareStage":
            self._prepare_stage_view_id = active_view_id

        if active_stage_id == "MonitorStage":
            return

        if active_view_id == "SimulationView":
            if active_stage_id != "PreviewStage":
                self._controller.setActiveStage("PreviewStage")
        else:
            if active_stage_id != "PrepareStage":
                self._controller.setActiveStage("PrepareStage")


    ##  Hackish way to ensure the proxy is already created, which ensures that the sidebargui.qml is already created
    #   as this caused some issues.
    def getProxy(self, engine, script_engine):
        return self._proxy
