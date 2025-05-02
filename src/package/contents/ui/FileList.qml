pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Grid {
    id: root
    width: parent.width
    required property var model
    property int maximumRows: -1
    columns: 2

    Repeater {
        id: fileListRepeater
        //model: maximumRows > 0 ? Math.min(maximumRows * columns, root.model.count) : root.model.count
        // delegate: KickoffGridDelegate {
        //     id: itemDelegate
        //     model: root.model
        //     index: appGridRepeater.index
        //     width: root.cellWidth
        //     Accessible.role: Accessible.Cell
        // }
        model: root.model
        delegate: KickoffListDelegate {
            id: itemDelegate
        }
    }
}