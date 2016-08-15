import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item{
    id:glowFrame
    width: ( icList.orientation === Qt.Horizontal ) ? wrapper.regulatorWidth : size
    height: ( icList.orientation === Qt.Vertical ) ? wrapper.regulatorHeight : size

    property int size: 8

    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }

    property color isActiveColor: theme.buttonFocusColor
    property color minimizedColor: plasmoid.configuration.threeColorsWindows ? "#e8e8e8" : isActiveColor // myPalette.mid
    property color isShownColor: plasmoid.configuration.threeColorsWindows ? "#717171" : isActiveColor // myPalette.shadow
    property color notActiveColor: mainItemContainer.hasMinimized ? minimizedColor : isShownColor

    Item{
        width: (( IsGroupParent ) && (icList.orientation === Qt.Horizontal)) ? 2*glowFrame.size : glowFrame.size
        height: (( IsGroupParent ) && (icList.orientation === Qt.Vertical)) ? 2*glowFrame.size : glowFrame.size
        anchors.centerIn: parent

        Flow{
            flow: ( icList.orientation === Qt.Vertical ) ? Flow.TopToBottom : Flow.LeftToRight
            GlowPoint{
                width: glowFrame.size
                height: width

                visible: ( !IsLauncher ) ? true: false

                basicColor: ((mainItemContainer.hasActive)&&(!(mainItemContainer.hasMinimized))) ?
                                 glowFrame.isActiveColor : glowFrame.notActiveColor

                showAttention: model.IsDemandingAttention ? true : false
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
