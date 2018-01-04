# Gimbal delta printer/CNC

The fundamental part of the gimbal delta printer is a 2-axis gimbal
holding a nut that takes a 1/4"-20 threaded rod. Each gimbal nut requires
four [684ZZ bearings](https://www.amazon.com/Bearing-684ZZ-4x9-Shielded-4x9x4/dp/B002BBKI7Q).
If you have four gimbal nuts, two mounted to one surface and two mounted
to another, you can have parallel arms as they are used in a
[Rostock delta printer](http://reprap.org/wiki/Delta_geometry) to keep the
tool mount platform horizontal. So you have three pairs of arms like a
Rostock, but instead of moving the upper ends of the arms up and down on linear
rails, you shorten and lengthen the three arm pairs. The gimbal nuts on the
tool mount platform are not allowed to rotate, and the threaded rods are epoxied
into their nuts, again to prevent rotation. The gimbal nuts on the printer frame,
at the upper ends of the arm pairs, are driven by a
[GT2 timing belt](http://sdp-si.com/products/timing-belts/gt2.php) to turn in
synchrony, maintaining the parallel-ness of the arm pairs. The belt for each pair
is driven by a stepper motor.
