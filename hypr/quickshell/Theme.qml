pragma Singleton
import QtQuick

QtObject {
    readonly property color colBg:     "#c4040d0d"
    readonly property color colFg:     "#a9b1d6"
    readonly property color colMuted:  "#444b6a"
    readonly property color colWhite:  "#ffefe7"
    readonly property color colCyan:   "#0db9d7"
    readonly property color colBlue:   "#7aa2f7"
    readonly property color colYellow: "#e0af68"
    readonly property color colGreen:  "#2c6b4d"
    readonly property color colPurple: "#da86f8"
    readonly property color colRed: '#ff3c4c'

    readonly property string fontFamily: "Iosevka Nerd Font"
    readonly property int    fontSize:    15

    readonly property int barHeight:      40
    readonly property int pillHeight:      33
    readonly property int pillPadding:     22
    readonly property int pillSpacing:      7
    readonly property int sectionSpacing:  8
    readonly property int edgeMargin:     14
}