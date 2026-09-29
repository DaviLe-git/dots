import QtQuick
import QtQuick.Layouts

import ".."              // ← NOVO
import "../widgets"

RowLayout {
    spacing: Theme.sectionSpacing
    Cpu      {}
    Volume   {}
    Battery  {}
    Bluetooth {}
    Network  {}
}