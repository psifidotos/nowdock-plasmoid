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
            anchors.fill: parent
            color: glowItem.basicColor
            radius: Math.min(width,height) / 2
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
            id:recGlow
            anchors.fill: smallCircle
            glowRadius: 2 * Math.min(smallCircle.width, smallCircle.height)
            spread: 0.2
            color: smallCircle.color
            //color: "#cc222222"
         //   cornerRadius: smallCircle.radius + glowRadius
            opacity: panel.showBarLine ? 0.25 : 0.45
            visible: panel.glow
        }

     /*   BrightnessContrast {
            anchors.fill: recGlow
            source: recGlow
            anchors.margins: 1
            brightness: 0.4
            contrast: 0.3
            visible: panel.glow
        }*/
    }



}
