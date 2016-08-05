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


    ColumnLayout {

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Behavior")
            flat: true

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
