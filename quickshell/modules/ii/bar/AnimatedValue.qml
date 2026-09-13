import QtQuick

QtObject {
    id: ctrl
    property real target: 0
    property real value: 0
    property int growMs: 300
    property int shrinkMs: 200
    property list<real> growCurve
    property list<real> shrinkCurve

    readonly property NumberAnimation anim: NumberAnimation {
        id: runner
        target: ctrl
        property: "value"
        alwaysRunToEnd: true
        easing.type: Easing.BezierSpline
    }

    function retarget() {
        if (!ctrl.ready) {
            ctrl.value = ctrl.target
            return
        }
        const gap = ctrl.target - ctrl.value
        if (Math.abs(gap) < 0.01 && !runner.running) {
            ctrl.value = ctrl.target
            return
        }
        runner.stop()
        runner.from = ctrl.value
        runner.to = ctrl.target
        runner.duration = gap >= 0 ? ctrl.growMs : ctrl.shrinkMs
        runner.easing.bezierCurve = gap >= 0 ? ctrl.growCurve : ctrl.shrinkCurve
        runner.start()
    }

    property bool ready: false
    Component.onCompleted: {
        ctrl.ready = true
        ctrl.value = ctrl.target
    }

    onTargetChanged: ctrl.retarget()
}