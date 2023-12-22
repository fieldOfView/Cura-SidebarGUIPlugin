# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The SidebarGUIPlugin is released under the terms of the AGPLv3 or higher.

import os.path
import json

try:
    from cura.ApplicationMetadata import CuraSDKVersion
except ImportError: # Cura <= 3.6
    CuraSDKVersion = "6.0.0"
if CuraSDKVersion >= "8.0.0":
    from PyQt6.QtCore import QUrl
    from PyQt6.QtGui import QDesktopServices
else:
    from PyQt5.QtCore import QUrl
    from PyQt5.QtGui import QDesktopServices

from cura.CuraApplication import CuraApplication
from UM.Extension import Extension
from UM.Message import Message
from UM.Version import Version

from UM.i18n import i18nCatalog

i18n_catalog = i18nCatalog("cura")


class SidebarIncompatibleVersion(Extension):
    HIDE_MESSAGE_PREFERENCE = "sidebargui/hide_incompatibility_message"
    
    def __init__(self):
        super().__init__()

        cura_version = CuraApplication.getInstance().getVersion()
        if cura_version == "master" or cura_version == "dev":
            cura_version = ""
        if cura_version.startswith("Arachne_engine"):
            cura_version = ""

        cura_version = Version(cura_version)
        cura_version = Version([cura_version.getMajor(), cura_version.getMinor()])

        # Get version information from plugin.json
        plugin_file_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), "plugin.json"
        )
        try:
            with open(plugin_file_path) as plugin_file:
                plugin_info = json.load(plugin_file)
                plugin_version = Version(plugin_info["version"])
        except Exception:
            plugin_version = Version()

        self._version_combination = "%s/%s" % (str(cura_version), str(plugin_version))

        preferences = CuraApplication.getInstance().getPreferences()
        preferences.addPreference(self.HIDE_MESSAGE_PREFERENCE, [])
        if self._version_combination in preferences.getValue(self.HIDE_MESSAGE_PREFERENCE):
            return

        self._incompatibility_message = Message(
            i18n_catalog.i18nc(
                "@info:status",
                "Using this version of the Sidebar GUI plugin with this version of Cura is untested and might cause issues so it is disabled. "
                "An updated version of the plugin may be available on github and/or (soon) in the Marketplace.",
            ),
            title=i18n_catalog.i18nc("@label", "Sidebar GUI"),
            option_text=i18n_catalog.i18nc("@info:option_text", "Do not show this message again for this version of Cura"),
            option_state=False,
        )
        self._incompatibility_message.optionToggled.connect(self._onDontTellMeAgain)
        self._incompatibility_message.addAction("github",
                           name = i18n_catalog.i18nc("@action:button", "Open Github..."),
                           icon = "",
                           description = "Visit the releases page on Github to check for a new version",
                           button_align = Message.ActionButtonAlignment.ALIGN_LEFT,
                           button_style=2)
        self._incompatibility_message.addAction("marketplace",
                           name = i18n_catalog.i18nc("@action:button", "Marketplace..."),
                           icon = "",
                           description = "Open Marketplace to check for a new version",
                           button_align = Message.ActionButtonAlignment.ALIGN_LEFT,
                           button_style=2)
        self._incompatibility_message.addAction("dismiss",
                           name = i18n_catalog.i18nc("@action:button", "Ok"),
                           icon = "",
                           description = "Dismiss this message",
                           button_align = Message.ActionButtonAlignment.ALIGN_RIGHT)
        self._incompatibility_message.actionTriggered.connect(self._onMessageAction)
        self._incompatibility_message.show()

    def _onDontTellMeAgain(self, checked: bool) -> None:
        preferences = CuraApplication.getInstance().getPreferences()

        version_combinations = set(preferences.getValue(self.HIDE_MESSAGE_PREFERENCE).split(","))
        if checked:
            version_combinations.add(self._version_combination)
        else:
            version_combinations.discard(self._version_combination)
        preferences.setValue(self.HIDE_MESSAGE_PREFERENCE, ";".join(version_combinations))

    def _onMessageAction(self, message, action) -> None:
        if action=="dismiss":
            message.hide()

        elif action=="github":
            QDesktopServices.openUrl(QUrl("https://github.com/fieldOfView/Cura-SidebarGUIPlugin/releases"))

        elif action=="marketplace":
            marketplace = CuraApplication.getInstance().getPluginRegistry().getPluginObject("Marketplace")
            if marketplace:
                marketplace.show()

