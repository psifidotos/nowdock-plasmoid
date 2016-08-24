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
    //property color isShownColor: plasmoid.configuration.threeColorsWindows ? panel.shownDotColor : isActiveColor
    property color isShownColor: isActiveColor
    property color minimizedColor: plasmoid.configuration.threeColorsWindows ? panel.minimizedDotColor : isActiveColor
    property color notActiveColor: mainItemContainer.hasMinimized ? minimizedColor : isShownColor

    Item{
        anchors.centerIn: parent

        width: flowItem.width
        height: flowItem.height

        Flow{
            id: flowItem
            flow: ( icList.orientation === Qt.Vertical ) ? Flow.TopToBottom : Flow.LeftToRight

            GlowPoint{
                id:firstPoint
                width: (mainItemContainer.hasActive && (!panel.vertical)) ? stateWidth : glowFrame.size
                height: (mainItemContainer.hasActive && (panel.vertical)) ? stateHeight : glowFrame.size
                visible: ( !IsLauncher ) ? true: false

                basicColor: (mainItemContainer.hasActive) ?
                                 glowFrame.isActiveColor : glowFrame.notActiveColor

                roundCorners: true
                showAttention: model.IsDemandingAttention ? true : false

                property int stateWidth: mainItemContainer.isGroupParent ? (wrapper.regulatorWidth - secondPoint.width) : wrapper.regulatorWidth - spacer.width
                property int stateHeight: mainItemContainer.isGroupParent ? wrapper.regulatorHeight - secondPoint.height : wrapper.regulatorHeight - spacer.height

               /*Behavior on width{
                    NumberAnimation{duration: (wrapper.scale != 1) ? 20:160; easing.type: Easing.InQuad}
                }
                Behavior on height{
                    NumberAnimation{duration: (wrapper.scale != 1) ? 20:160; easing.type: Easing.InQuad}
                }*/
            }

            Item{
                id:spacer
                width: mainItemContainer.isGroupParent ? 0.5*glowFrame.size : 0
                height: mainItemContainer.isGroupParent ? 0.5*glowFrame.size : 0
            }

            GlowPoint{
                id:secondPoint
                width: visible ? glowFrame.size : 0
                height: width

                basicColor: ((mainItemContainer.hasActive)&&(!(mainItemContainer.hasMinimized))) ? state2Color : state1Color
                roundCorners: true
                visible:  ( mainItemContainer.isGroupParent && plasmoid.configuration.dotsOnActive )
                         || (mainItemContainer.isGroupParent && !mainItemContainer.hasActive)? true: false

                //when there is no active window
                property color state1Color: mainItemContainer.hasShown ? glowFrame.isShownColor : glowFrame.minimizedColor
                //when there is active window
                property color state2Color: mainItemContainer.hasMinimized ? glowFrame.minimizedColor : glowFrame.isShownColor
            }
        }
    }
}// number of windows indicator
