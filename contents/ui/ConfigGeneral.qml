/***************************************************************************
 *   Copyright (C) 2013 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    width: childrenRect.width
    height: childrenRect.height

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)

    property alias cfg_wheelEnabled: wheelEnabled.checked
    property alias cfg_smartLaunchersEnabled: smartLaunchers.checked
    property alias cfg_middleClickAction: middleClickAction.currentIndex

    property alias cfg_showOnlyCurrentScreen: showOnlyCurrentScreen.checked
    property alias cfg_showOnlyCurrentDesktop: showOnlyCurrentDesktop.checked
    property alias cfg_showOnlyCurrentActivity: showOnlyCurrentActivity.checked

    property alias cfg_showBarLine: showBarLine.checked
    property alias cfg_showShadows: showShadows.checked
    property alias cfg_showGlow: showGlow.checked
    property alias cfg_zoomLevel: zoomLevel.value
    property alias cfg_iconSize: iconSize.value

    ColumnLayout {
        spacing: 15
        Layout.fillWidth: true

        GroupBox {
            title: i18n("Appearance")
            flat: true
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: showBarLine
                    text: i18n("Show bar line for tasks")
                    enabled: true
                }

                CheckBox {
                    id: showShadows
                    text: i18n("Enable shadows for icons")
                    enabled: true
                }

                CheckBox {
                    id: showGlow
                    text: i18n("Show glow around windows points")
                    enabled: true
                }
            }
        }

        GroupBox {
            title: i18n("Zoom")
            flat: true
            Layout.fillWidth: true


            GridLayout{
                Layout.fillWidth: true
                columns: 3

                Label {
                    text: i18n("Zoom Level: ")
                }

                Slider {
                    id: zoomLevel
                    Layout.fillWidth: true
                    minimumValue: 1
                    maximumValue: 20
                    stepSize: 1
                    tickmarksEnabled: true
                }

                Label {
                    Layout.maximumWidth: 25
                    text: ( 1 + (zoomLevel.value / 20) )
                }

                Label {
                    text: i18n("Icon size: ")
                }

                Slider {
                    id: iconSize
                    Layout.fillWidth: true
                    minimumValue: -32
                    maximumValue: 64
                    stepSize: 1
                }

                Label {
                    Layout.maximumWidth: 25
                    text: iconSize.value + i18n(" px.")
                }

                Label {
                    text: ""
                }

                Label {
                    text: i18n("Notice: 0px. is the default Huge icon size in Plasma")
                    font.italic: true
                    Layout.columnSpan: 2
                }
            }

        }


        GroupBox {
            title: i18n("Behavior")
            flat: true
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: wheelEnabled
                    text: i18n("Cycle through tasks with mouse wheel")
                    enabled: false
                }

                CheckBox {
                    id: smartLaunchers
                    Layout.fillWidth: true
                    text: i18n("Show progress and status information in task buttons")
                    enabled: false
                }

                RowLayout {
                    Label {
                        text: i18n("On middle-click:")
                    }

                    ComboBox {
                        id: middleClickAction
                        Layout.fillWidth: true
                        model: [i18nc("The click action", "None"), i18n("Close Window or Group"), i18n("New Instance"), i18n("Minimize/Restore Window or Group")]
                    }
                }
            }
        }


        GroupBox {
            Layout.fillWidth: true

            title: i18n("Filters")
            flat: true

            ColumnLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: showOnlyCurrentScreen
                    text: i18n("Show only tasks from the current screen")
                }

                CheckBox {
                    id: showOnlyCurrentDesktop
                    text: i18n("Show only tasks from the current desktop")
                }

                CheckBox {
                    id: showOnlyCurrentActivity
                    text: i18n("Show only tasks from the current activity")
                }
            }
        }
    }
}
