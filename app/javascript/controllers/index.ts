import { Application } from "@hotwired/stimulus"

import ThemeController from "./theme_controller"
import DropdownController from "./dropdown_controller"
import SdkIntegrationController from "./sdk_integration_controller"
import ClipboardController from "./clipboard_controller"
import TomSelectController from "./tom_select_controller"
import FlatpickrController from "./flatpickr_controller"
import SystemMonitorController from "./system_monitor_controller"
import FlashController from "./flash_controller"
import LessonCardController from "./lesson_card_controller"
import QiniuPlayerController from "./qiniu_player_controller"
import SidebarController from "./sidebar_controller"
import PwaInstallController from "./pwa_install_controller"
import ViewToggleController from "./view_toggle_controller"
import CalendarViewController from "./calendar_view_controller"

const application = Application.start()

application.register("theme", ThemeController)
application.register("dropdown", DropdownController)
application.register("sdk-integration", SdkIntegrationController)
application.register("clipboard", ClipboardController)
application.register("tom-select", TomSelectController)
application.register("flatpickr", FlatpickrController)
application.register("system-monitor", SystemMonitorController)
application.register("flash", FlashController)
application.register("lesson-card", LessonCardController)
application.register("qiniu-player", QiniuPlayerController)
application.register("sidebar", SidebarController)
application.register("pwa-install", PwaInstallController)
application.register("view-toggle", ViewToggleController)
application.register("calendar-view", CalendarViewController)

window.Stimulus = application
