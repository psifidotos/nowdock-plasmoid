import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components

import QtGraphicalEffects 1.0

Item{
    //   property string color
    id: glowItem  

    property color basicColor: "blue"
    property color attentionColor: colorScopePalette.negativeTextColor // "#ffff1717"

    property bool showAttention: false

    property int animation: 1500

    onShowAttentionChanged: {
        if(showAttention == false){
            smallCircle.color = basicColor;
        }
    }

    Item{
        id:mainGlow
        anchors.fill: parent

        Rectangle {
            id: smallCircle
            property int incSizeAttention: (showAttention == false) ? 0 : 0

            width: Math.round(parent.width / 1.8) + incSizeAttention
            height: Math.round(parent.height / 1.8) + incSizeAttention
            color: glowItem.basicColor
            radius: width*0.5
            anchors.centerIn: parent

            SequentialAnimation{
                running: (glowItem.showAttention == true)
                loops: Animation.Infinite

                PropertyAnimation {
                    target: smallCircle
                    property: "color"
                    to: glowItem.attentionColor
                    duration: glowItem.animation
                    easing.type: Easing.InOutQuad
                }

                PropertyAnimation {
                    target:smallCircle
                    property: "color"
                    to: glowItem.basicColor
                    duration: glowItem.animation
                    easing.type: Easing.InOutQuad
                }
            }
        }

       RectangularGlow {
            anchors.fill: smallCircle
            glowRadius: 2 * smallCircle.width
            spread: 0.01
            color: smallCircle.color
            cornerRadius: smallCircle.radius + glowRadius
            opacity: 0.4
            visible: panel.glow
        }

        BrightnessContrast {
            anchors.fill: smallCircle
            source: smallCircle
            anchors.margins: 1
            brightness: 0.4
            contrast: 0.3
            visible: panel.glow
        }
    }



}
