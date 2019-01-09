# Copyright (c) 2019 fieldOfView
# The SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

from UM.Application import Application
from UM.FlameProfiler import pyqtSlot

from PyQt5.QtCore import QObject

class SidebarGUIProxy(QObject):
    def __init__(self, parent = None) -> None:
        super().__init__(parent)

    @pyqtSlot("QVariant", result = bool)
    def getExtruderHasQualityForMaterial(self, extruder_stack):
        application = Application.getInstance()
        global_stack = application.getGlobalContainerStack()
        if not global_stack:
            return False

        if not global_stack.getMetaDataEntry("has_machine_materials"):
            return True

        container_registry = application.getContainerRegistry()
        material_manager = application.getMaterialManager()

        fallback_material = material_manager.getFallbackMaterialIdByMaterialType(extruder_stack.material.getMetaDataEntry("material"))

        search_criteria = {
            "type": "quality",
            "material": fallback_material
        }

        if global_stack.getMetaDataEntry("has_machine_quality"):
            search_criteria["definition"] = global_stack.definition.id
        else:
            search_criteria["definition"] = "fdmprinter"
        if global_stack.getMetaDataEntry("has_variants"):
            search_criteria["variant"] = extruder_stack.variant.name

        containers_metadata = container_registry.findInstanceContainersMetadata(**search_criteria)

        return containers_metadata != []
