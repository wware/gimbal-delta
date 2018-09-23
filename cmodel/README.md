# Calibration model

This is a mathematical model for calibrating the gimbal delta machine. The hope is to get fairly high positional precision, hopefully a millimeter or better.

The pairs of threaded rods can be modeled as two points, and one of those points can be the tooltip. Applying that to all three pairs, we have an inverted tetrahedron whose lower vertex is the tooltip. The calibration process involves using some kind of least-squares method to find the other three vertices and the lengths of the edges connecting them to the tooltip vertex.

Logistically, the procedure is to begin with approximate values for all these things that are good enough to move the tooltip around in predictable directions and distances, and then lower the tooltip onto several points on a flat surface. The locations of those points are known. Using that knowledge and the controls we used to position the tooltip, we should be able to figure out more accurate values.

## Setting up the kinematics problems

We want to find three lengths and three points, or a total of 12 scalars, so we'll need at least 12 points on our reference surface.

Let's assume that we have nominal rod lengths and our controls are deltas from those nominal lengths. Let those lengths be La, Lb, and Lc, and the tops of those rods are the points (xa, ya, za), (xb, yb, zb), and (xc, yc, zc) respectively. The length deltas can be Da, Db, and Dc.

The forward kinematics problem is to map (Da, Db, Dc) to the position of the tooltip (x, y, z). The inverse kinematics problem is to map (x, y, z) to (Da, Db, Dc). Surprisingly, the inverse kinematics problem is easier to solve.

    # Given all our parameters...
    X = np.array((x, y, z))
    A = np.array((xa, ya, za))
    B = np.array((xb, yb, zb))
    C = np.array((xc, yc, zc))
    Da = linalg.norm(A - X) - La
    Db = linalg.norm(B - X) - Lb
    Dc = linalg.norm(C - X) - Lc

To solve the forward kinematics problem, we need to specify (Da, Db, Dc) and then find the vector X representing the intersection of three spheres. This is a solved problem, discussed [here](https://stackoverflow.com/questions/1406375) and [here](https://gis.stackexchange.com/questions/66). Given the function defined in the last Stack Overflow answer, we can write

    x, y, z = trilaterate(A, B, C, La + Da, Lb + Db, Lc + Dc)

where the definition of `trilaterate` is given in `hack.py` in this directory. Gee, that was easier than I expected. OK, on to formulating the least-squares method.

## Dealing with unknowns and their consequent errors

Recognize that the values we have for A, B, C, La, Lb, Lc are approximations (known but not quite correct) of the real values (correct but unknown). So we have *our* answer and *the right* answer. `F` is the function whose input is the controls and parameters, and whose output is the tooltip position.

    X~ = F(Da, Db, Dc, A~, B~, C~, La~, Lb~, Lc~)     # estimated parameters, known but approximate
    X = F(Da, Db, Dc, A, B, C, La, Lb, Lc)            # real paramaters, unknown but correct

So set up a square error figure, summed over several datapoints. Each datapoint starts with the control point `D` (that is, Da, Db, Dc) and is mapped by `F` (along with parameters) to the `X` (or `X~`) vector.

    E = sum([linalg.norm(X - X~) ** 2 for D in manyDs])
    partial dE/dparam = 2 * sum([linalg.norm(X - X~) * (dX~/dparam) for D in manyDs])

One can now construct a 12-dimensional vector of partial derivatives defined for any point in the twelve-space `A, B, C, La, Lb, Lc` of parameters. We want to find the point in 12-space where all twelve partial derivatives are zero, indicating a minimum square error.

It won't be practical to find a closed form for `dX/dparam`, so I'll need to iterate a [Newton's method](https://en.wikipedia.org/wiki/Newton%27s_method) or [gradient descent](https://en.wikipedia.org/wiki/Gradient_descent) or whatever to solve this.
