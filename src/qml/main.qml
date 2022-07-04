/*
    SPDX-FileCopyrightText: 2022 Vlad Zahorodnii <vlad.zahorodnii@kde.org>

    SPDX-License-Identifier: GPL-3.0-only
*/

import QtQuick 2.15
import QtQuick3D 1.15
import QtQuick3D.Helpers 1.15
import org.kde.kwin 3.0 as KWinComponents
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root
    focus: true

    required property QtObject effect
    required property QtObject targetScreen

    readonly property bool debug: false
    property bool animationEnabled: false

    function switchToSelected() {
        KWinComponents.Workspace.currentVirtualDesktop = cube.selectedDesktop;
        effect.deactivate();
    }

    View3D {
        id: view
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: "black"
            backgroundMode: SceneEnvironment.Color
        }

        Loader {
            active: root.debug
            sourceComponent: AxisHelper {}
        }
        Loader {
            active: root.debug
            sourceComponent: DebugView {
                source: view
            }
        }

        PerspectiveCamera {
            id: perspectiveCamera
            position: Qt.vector3d(0, 0, cube.faceDistance + (0.5 * cube.faceSize.height * Math.tan(fieldOfView * Math.PI / 180)) * effect.distanceFactor)
        }

        OrbitCameraController {
            id: orbitController
            anchors.fill: parent
            origin: cube
            camera: perspectiveCamera
            xInvert: effect.mouseInvertedX
            yInvert: effect.mouseInvertedY
        }

        Cube {
            id: cube
            faceDisplacement: effect.cubeFaceDisplacement
            faceSize: Qt.size(root.width, root.height)

            Behavior on eulerRotation {
                enabled: !orbitController.inputsNeedProcessing && root.animationEnabled
                Vector3dAnimation { duration: PlasmaCore.Units.longDuration; easing.type: Easing.InOutCubic }
            }
        }
    }

    MouseArea {
        anchors.fill: view
        onClicked: root.switchToSelected();
    }

    Keys.onEscapePressed: effect.deactivate();
    Keys.onLeftPressed: cube.rotateToLeft();
    Keys.onRightPressed: cube.rotateToRight();
    Keys.onEnterPressed: root.switchToSelected();
    Keys.onReturnPressed: root.switchToSelected();
    Keys.onSpacePressed: root.switchToSelected();

    Component.onCompleted: {
        cube.rotateTo(KWinComponents.Workspace.currentVirtualDesktop);
        root.animationEnabled = true;
    }
}
