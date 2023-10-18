import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import Qt3D.Core 2.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600


    Canvas {
        anchors.fill: parent

        //axes rotation to world
        property var myRwa: { "w": 1, "x": 0, "y": 0, "z": 0 }


        //camera rotation
        property var myRwc: {
            "w": 1,
            "x": 0,
            "y": 0,
            "z": 0}
        //camera pose
        property var twc: {"x": 0,"y": 0,"z": 5}


        //var quaternion= { w: 1, x: 0, y: 0, z: 0 }
        //var quaternion = { w: 1, x: 0, y: 0, z: 0 }
        property real angle: 0

        Timer {
                        interval: 50
            running: true
            repeat: true
            onTriggered: {
                parent.angle += 0.1
                function quaternionFromAngleAxis(angle, axis) {
                    var s = Math.sin(angle / 2);
                    return {
                        w: Math.cos(angle / 2),
                        x: axis.x * s,
                        y: axis.y * s,
                        z: axis.z * s
                    };
                }

                parent.myRwa = quaternionFromAngleAxis(parent.angle, {x: 0, y: 0.7, z: 0.7});


                parent.requestPaint()
            }
        }

        //cal and paint
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            // Rest of the previous code ...
            function multiplyQuaternion(q1, q2) {
                var w1 = q1.w, x1 = q1.x, y1 = q1.y, z1 = q1.z;
                var w2 = q2.w, x2 = q2.x, y2 = q2.y, z2 = q2.z;
                var result = {
                    w: w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2,
                    x: w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2,
                    y: w1 * y2 - x1 * z2 + y1 * w2 + z1 * x2,
                    z: w1 * z2 + x1 * y2 - y1 * x2 + z1 * w2
                };
                return result;
            }


            function conjugateQuaternion(q) {
                return { w: q.w, x: -q.x, y: -q.y, z: -q.z };
            }

            function transform_point_to_camera(p) {
                // Step 1: Rotate the point in world space
                var qpoint = { w: 0, x: p.x, y: p.y, z: p.z }
                var worldSpacePoint = multiplyQuaternion(myRwa, multiplyQuaternion(qpoint, conjugateQuaternion(myRwa)))

                // Step 2: Rotate the point to the camera frame
                var cameraSpacePoint = multiplyQuaternion(myRwc, multiplyQuaternion(worldSpacePoint, conjugateQuaternion(myRwc)))

                // Step 3: Translate the point using the camera's position
                return { x: cameraSpacePoint.x + twc.x, y: cameraSpacePoint.y + twc.y, z: cameraSpacePoint.z + twc.z }
            }


            // Continue the rest of the previous code for projection and rendering
            function project(p) {
                var focalLength = 500
                return {
                    x: focalLength * p.x / p.z + width / 2,
                    y: height / 2 - focalLength * p.y / p.z
                }
            }


            var origin = {x:0, y:0, z:0}

            var origin_camera_space = transform_point_to_camera(origin)

             var xAxisEnd_camera_space = transform_point_to_camera({ x: 1, y: 0, z: 0 })
             var yAxisEnd_camera_space = transform_point_to_camera({ x: 0, y: 1, z: 0 })
             var zAxisEnd_camera_space = transform_point_to_camera({ x: 0, y: 0, z: 1 })

            //console.log("trans:", yAxisEnd_camera_space.x, yAxisEnd_camera_space.y, yAxisEnd_camera_space.z)

             var origin_projected = project(origin_camera_space)
             var xAxisEnd_projected = project(xAxisEnd_camera_space)
             var yAxisEnd_projected = project(yAxisEnd_camera_space)
             var zAxisEnd_projected = project(zAxisEnd_camera_space)

            //console.log(yAxisEnd_projected.x, yAxisEnd_projected.y)

            ctx.lineWidth = 6;

            // 绘制X轴
            ctx.strokeStyle = "red"
            ctx.beginPath()
            ctx.moveTo(origin_projected.x, origin_projected.y)
            ctx.lineTo(xAxisEnd_projected.x, xAxisEnd_projected.y)
            ctx.stroke()

            // 绘制Y轴
            ctx.strokeStyle = "green"
            ctx.beginPath()
            ctx.moveTo(origin_projected.x, origin_projected.y)
            ctx.lineTo(yAxisEnd_projected.x, yAxisEnd_projected.y)
            ctx.stroke()

            // 绘制Z轴
            ctx.strokeStyle = "blue"
            ctx.beginPath()
            ctx.moveTo(origin_projected.x, origin_projected.y)
            ctx.lineTo(zAxisEnd_projected.x, zAxisEnd_projected.y)
            ctx.stroke()
        }
    }
}
