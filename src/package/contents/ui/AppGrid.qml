pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Grid {
    id: root
    required property var model
    required property int availableWidth
    property int cellWidth: KickoffSingleton.gridCellSize
    property int maximumRows: -1

    columns: Math.floor(availableWidth / cellWidth)

    Repeater {
        id: appGridRepeater
        //model: maximumRows > 0 ? Math.min(maximumRows * columns, root.model.count) : root.model.count
        // delegate: KickoffGridDelegate {
        //     id: itemDelegate
        //     model: root.model
        //     index: appGridRepeater.index
        //     width: root.cellWidth
        //     Accessible.role: Accessible.Cell
        // }
        model: root.model
        delegate: KickoffGridDelegate {
            id: itemDelegate
            width: root.cellWidth
            Accessible.role: Accessible.Cell
        }
    }
}