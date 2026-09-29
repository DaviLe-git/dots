import QtQuick
import QtQuick.Layouts

import ".."              // ← NOVO
import "../widgets"

RowLayout {
    spacing: Theme.sectionSpacing
    Clock      {}
    Workspaces {}
}