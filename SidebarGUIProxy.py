# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

from UM.Application import Application
from UM.Logger import Logger
from UM.FlameProfiler import pyqtSlot

try:
    from cura.ApplicationMetadata import CuraSDKVersion
except ImportError: # Cura <= 3.6
    CuraSDKVersion = "6.0.0"
if CuraSDKVersion >= "8.0.0":
    from PyQt6.QtCore import QObject, QRectF
else:
    from PyQt5.QtCore import QObject, QRectF

try:
    from cura.Machines.ContainerTree import ContainerTree
except ImportError:
    ContainerTree = None  # type: ignore

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from cura.Settings.ExtruderStack import ExtruderStack

class SidebarGUIProxy(QObject):
    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        Logger.log("d", "SidebarGUI proxy created")

    @pyqtSlot("QVariant", result=bool)
    def getExtruderHasQualityForMaterial(self, extruder_stack: "ExtruderStack") -> bool:
        application = Application.getInstance()
        global_stack = application.getGlobalContainerStack()
        if not global_stack or not extruder_stack:
            return False

        if not global_stack.getMetaDataEntry("has_materials"):
            return True

        if ContainerTree is not None:
            # Post Cura 4.4; use ContainerTree to find out if there are supported qualities
            machine_node = ContainerTree.getInstance().machines[global_stack.definition.getId()]

            active_variant_name = extruder_stack.variant.getMetaDataEntry("name")
            try:
                active_variant_node = machine_node.variants[active_variant_name]
            except KeyError:
                Logger.log("w", "Could not find the variant %s", active_variant_name)
                return True

            material_base_file = extruder_stack.material.getMetaDataEntry("base_file")
            try:
                active_material_node = active_variant_node.materials[material_base_file]
            except KeyError:
                Logger.log("w", "Could not find material %s for the current variant", material_base_file)
                return False

            active_material_node_qualities = active_material_node.qualities
            if not active_material_node_qualities:
                return False
            return list(active_material_node_qualities.keys())[0] != "empty_quality"

        else:
            # Pre Cura 4.4; use MaterialManager et al to find out if there are supported qualities
            search_criteria = {
                "type": "quality",
            }

            if global_stack.getMetaDataEntry("has_machine_quality"):
                search_criteria["definition"] = global_stack.getMetaDataEntry(
                    "quality_definition", global_stack.definition.id
                )
            else:
                return True

            container_registry = application.getContainerRegistry()
            if hasattr(application, "getMaterialManager"):
                material_manager = application.getMaterialManager()

                fallback_material = (
                    material_manager.getFallbackMaterialIdByMaterialType(
                        extruder_stack.material.getMetaDataEntry("material")
                    )
                )
                search_criteria["material"] = fallback_material

            if global_stack.getMetaDataEntry("has_variants"):
                search_criteria["variant"] = extruder_stack.variant.name

            containers_metadata = container_registry.findInstanceContainersMetadata(
                **search_criteria
            )

            return containers_metadata != []

    @pyqtSlot("QVariant", result=bool)
    def checkRectangleOnScreen(self, rectangle):
        # Check if rectangle is not outside the currently available screens
        application = Application.getInstance()
        screen_found = False
        try:
            # Qt6, Cura 5.0 and later
            for screen in application.screens():
                if rectangle.intersects(QRectF(screen.availableGeometry())):
                    screen_found = True
                    break
        except AttributeError:
            # Qt5, Cura 4.13 and before
            for screen_number in range(0, application.desktop().screenCount()):
                if rectangle.intersects(
                    QRectF(application.desktop().availableGeometry(screen_number))
                ):
                    screen_found = True
                    break
        if not screen_found:
            return False
        return True
