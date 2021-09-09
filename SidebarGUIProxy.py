# Copyright (c) 2021 Aldo Hoeben / fieldOfView
# The SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

from UM.Application import Application
from UM.Logger import Logger
from UM.FlameProfiler import pyqtSlot

from PyQt5.QtCore import QObject, QRectF

try:
    from cura.Machines.ContainerTree import ContainerTree
except ImportError:
    ContainerTree = None  # type: ignore


class SidebarGUIProxy(QObject):
    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        Logger.log("d", "SidebarGUI proxy created")

    @pyqtSlot("QVariant", result=bool)
    def getExtruderHasQualityForMaterial(self, extruder_stack):
        application = Application.getInstance()
        global_stack = application.getGlobalContainerStack()
        if not global_stack or not extruder_stack:
            return False

        if not global_stack.getMetaDataEntry("has_materials"):
            return True

        if ContainerTree is not None:
            # Post Cura 4.4; use ContainerTree to find out if there are supported qualities
            container_tree = ContainerTree.getInstance()
            machine_node = container_tree.machines[global_stack.definition.getId()]
            nodes = set()  # type: Set[MaterialNode]

            active_variant_name = extruder_stack.variant.getMetaDataEntry("name")
            if active_variant_name not in machine_node.variants:
                Logger.log("w", "Could not find the variant %s", active_variant_name)
                return True
            active_variant_node = machine_node.variants[active_variant_name]
            active_material_node = active_variant_node.materials[
                extruder_stack.material.getMetaDataEntry("base_file")
            ]

            return list(active_material_node.qualities.keys())[0] != "empty_quality"

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
        for screen_number in range(0, application.desktop().screenCount()):
            if rectangle.intersects(
                QRectF(application.desktop().availableGeometry(screen_number))
            ):
                screen_found = True
                break
        if not screen_found:
            return False
        return True
