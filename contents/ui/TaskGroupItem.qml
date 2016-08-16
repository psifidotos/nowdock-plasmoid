import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item{
    id:glowFrame
    width: ( icList.orientation === Qt.Horizontal ) ? wrapper.regulatorWidth : size
    height: ( icList.orientation === Qt.Vertical ) ? wrapper.regulatorHeight : size

    //property int size: Math.ceil( panel.iconSize/13 ) //5
    property int size: wrapper.statesLineSize

    //SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }

    property color isActiveColor: theme.buttonFocusColor
    property color minimizedColor: plasmoid.configuration.threeColorsWindows ? "#e8e8e8" : isActiveColor // myPalette.mid
    property color isShownColor: plasmoid.configuration.threeColorsWindows ? "#717171" : isActiveColor // myPalette.shadow
    property color notActiveColor: mainItemContainer.hasMinimized ? minimizedColor : isShownColor

    Item{
        width: flowItem.width
        height: flowItem.height
        anchors.centerIn: parent

        Flow{
            id: flowItem
            flow: ( icList.orientation === Qt.Vertical ) ? Flow.TopToBottom : Flow.LeftToRight

            GlowPoint{
                width: (mainItemContainer.hasActive && (!panel.vertical)) ? stateWidth : glowFrame.size
                height: (mainItemContainer.hasActive && (panel.vertical)) ? stateHeight : glowFrame.size
                visible: ( !IsLauncher ) ? true: false

                basicColor: (mainItemContainer.hasActive) ?
                                 glowFrame.isActiveColor : glowFrame.notActiveColor

                showAttention: model.IsDemandingAttention ? true : false

                property int stateWidth: IsGroupParent ? (wrapper.regulatorWidth - glowFrame.size) : wrapper.regulatorWidth - spacer.width
                property int stateHeight: IsGroupParent ? wrapper.regulatorHeight - glowFrame.size : wrapper.regulatorHeight - spacer.height

                Behavior on width{
                    NumberAnimation{duration: mainItemContainer.containsMouse ? 20:160; easing.type: Easing.InQuad}
                }
                Behavior on height{
                    NumberAnimation{duration: mainItemContainer.containsMouse ? 20:160; easing.type: Easing.InQuad}
                }
            }

            Item{
                id:spacer
                width: IsGroupParent ? 0.5*glowFrame.size : 0
                height: IsGroupParent ? 0.5*glowFrame.size : 0
            }

            GlowPoint{
                width: glowFrame.size
                height: width

                visible: (IsGroupParent) ? true: false

                //when there is no active window
                property color state1Color: mainItemContainer.hasShown ? glowFrame.isShownColor : glowFrame.minimizedColor
                //when there is active window
                property color state2Color: mainItemContainer.hasMinimized ? glowFrame.minimizedColor : glowFrame.isShownColor
                basicColor: ((mainItemContainer.hasActive)&&(!(mainItemContainer.hasMinimized))) ? state2Color : state1Color

            }
        }
    }
}// number of windows indicator
