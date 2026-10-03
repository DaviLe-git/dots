import QtQuick
import QtQuick.Layouts

import ".."
import "../widgets"

RowLayout {
    spacing: Theme.sectionSpacing
    Cpu      {}
    Volume   {}
    Battery  {}
    Bluetooth {}
    Network  {}
    Config {}
}