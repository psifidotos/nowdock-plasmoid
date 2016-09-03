/*
 *  Copyright 2013 Michail Vourlakos <mvourlakos@gmail.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    width: childrenRect.width
    height: childrenRect.height

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)

    property alias cfg_showShadows: showShadows.checked
    property alias cfg_showGlow: showGlow.checked
    property alias cfg_zoomLevel: zoomLevel.value
    property alias cfg_iconSize: iconSizeCmb.realValue
    property alias cfg_zoomHelper: zoomHelper.checked
    property alias cfg_threeColorsWindows: threeColorsWindows.checked
    property alias cfg_dotsOnActive: dotsOnActive.checked
    property alias cfg_showBarLine: showBarLine.checked
    property alias cfg_useThemePanel: useThemePanel.checked
    property alias cfg_panelSize: panelSize.value
    property alias cfg_transparentPanel: transparentPanel.checked
    property alias cfg_plasmoidPosition: panelPositionCmb.currentIndex

    ColumnLayout {
        spacing: 15
        Layout.fillWidth: true

        GroupBox {
            title: ""
            flat: true
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true

                RowLayout{
                    Label {
                        text: i18n("Icon size: ")
                    }

                    ComboBox {
                        // 16, 22, 32, 48, 64,128, 256
                        id: iconSizeCmb

                        property int realValue
                        property bool startup: true
                        model: ["16px.", "22px.", "32px.", "48px.", "64px.", "92px", "128px.", "256px."]

                        onCurrentIndexChanged: {
                            switch(currentIndex){
                            case 0:
                                realValue = 16;
                                break;
                            case 1:
                                realValue = 22;
                                break;
                            case 2:
                                realValue = 32;
                                break;
                            case 3:
                                realValue = 48;
                                break;
                            case 4:
                                realValue = 64;
                                break;
                            case 5:
                                realValue = 92;
                                break;
                            case 6:
                                realValue = 128;
                                break;
                            case 7:
                                realValue = 256;
                                break;
                            default:
                                realValue = 64;
                                break
                            }
                        }

                        onRealValueChanged: {
                            if(startup){
                                switch (realValue){
                                case 16:
                                    currentIndex = 0;
                                    break;
                                case 22:
                                    currentIndex = 1;
                                    break;
                                case 32:
                                    currentIndex = 2;
                                    break;
                                case 48:
                                    currentIndex = 3;
                                    break;
                                case 64:
                                    currentIndex = 4;
                                    break;
                                case 92:
                                    currentIndex = 5;
                                    break;
                                case 128:
                                    currentIndex = 6;
                                    break;
                                case 256:
                                    currentIndex = 7;
                                    break;
                                default:
                                    currentIndex = 4;
                                    break
                                }
                                startup = false;
                            }
                        }
                    }
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

                CheckBox {
                    id: threeColorsWindows
                    text: i18n("Different color for minimized windows")
                    enabled: true
                }

                CheckBox {
                    id: dotsOnActive
                    text: i18n("Dots on active window")
                    enabled: true
                }

                Label{}


                GridLayout{
                    Layout.fillWidth: true
                    columns: 3
                    property bool panelConfigEnabled: showBarLine.checked && useThemePanel.checked

                    Item{
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        Label {
                            text: i18n("Panel")
                            anchors.centerIn: parent
                            font.bold: true
                            font.italic: true
                        }
                    }
                    Label {
                        text: i18n("Position: ")
                    }

                    ComboBox {
                        // 16, 22, 32, 48, 64,128, 256
                        id: panelPositionCmb

                        Layout.fillWidth: true
                        model: ["Center", "Left", "Right", "Top", "Bottom"]
                    }
                    Label{}


                    CheckBox {
                        id: showBarLine
                        Layout.columnSpan: 3
                        text: i18n("Show bar line for tasks")
                        enabled: true
                    }

                    CheckBox {
                        id: useThemePanel
                        Layout.columnSpan: 3
                        text: i18n("Use plasma theme panel")
                        enabled: showBarLine.checked
                    }

                    CheckBox {
                        id: transparentPanel
                        Layout.columnSpan: 3
                        text: i18n("Use transparency in the panel")
                        enabled: parent.panelConfigEnabled
                    }


                    Label {
                        id: panelLabel
                        text: i18n("Size: ")
                        enabled: parent.panelConfigEnabled
                    }

                    Slider {
                        id: panelSize
                        enabled: parent.panelConfigEnabled
                        Layout.fillWidth: true
                        minimumValue: 0
                        maximumValue: 256
                        stepSize: 2
                        tickmarksEnabled: false
                    }

                    Label {
                        enabled: parent.panelConfigEnabled
                        Layout.minimumWidth: metricsLabel.width
                        Layout.maximumWidth: metricsLabel.width
                        Layout.alignment: Qt.AlignRight
                        horizontalAlignment: Text.AlignRight

                        text: ( panelSize.value + " px." )

                        Label{
                            id:metricsLabel
                            visible: false
                            text: panelSize.maximumValue+" px."
                        }
                    }

                /*    Label{
                        Layout.columnSpan: 3
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignRight
                        Layout.maximumWidth: zoomLevel.width + zoomLevelText.width + panelLabel.width
                        horizontalAlignment: Text.AlignRight
                        text: i18n("in panel placement, themes that have set a <b>specific</b> panel transparent work better")
                        wrapMode: Text.WordWrap
                        font.italic: true
                        enabled: parent.panelConfigEnabled
                    }*/

                    Label{Layout.columnSpan: 3}
                    Label{Layout.columnSpan: 3}

                    Item{
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        Label {
                            text: i18n("Zoom")
                            anchors.centerIn: parent
                            font.bold: true
                            font.italic: true
                        }
                    }

                    //////

                    Label {
                        text: i18n("Level: ")
                    }

                    Slider {
                        id: zoomLevel
                        Layout.fillWidth: true
                        minimumValue: 0
                        maximumValue: 20
                        stepSize: 1
                        tickmarksEnabled: true
                    }

                    Label {
                        id:zoomLevelText
                        Layout.minimumWidth: metricsLabel2.width
                        Layout.maximumWidth: metricsLabel2.width
                        Layout.alignment: Qt.AlignRight


                        property real fixedZoom: (1 + (zoomLevel.value / 20))
                        text:  "x"+ fixedZoom.toFixed(2)

                        Label{
                            id:metricsLabel2
                            visible: false
                            text: "x1.50"
                        }
                    }
                    /////
                    //spacer to set a minimumWidth for sliders
                    //Layout.minimumWidth didnt work
                    Label{}
                    Label{Layout.minimumWidth: 275}
                    Label{}

                    ////////

                    CheckBox {
                        id: zoomHelper
                        text: i18n("Show a red line on the limit needed for animations")
                        enabled: true
                        Layout.columnSpan: 3
                    }

                }

            }
        }
    }
}
