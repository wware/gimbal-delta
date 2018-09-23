import numpy
from numpy import sqrt, dot, cross
from numpy.linalg import norm

def trilaterate(P1, P2, P3, r1, r2, r3):
    """
    Find the intersection of three spheres
    P1, P2, P3 are the centers, r1, r2, r3 are the radii
    Implementaton based on Wikipedia Trilateration article.
    """
    temp1 = P2 - P1
    e_x = temp1 / norm(temp1)
    temp2 = P3 - P1
    i = dot(e_x, temp2)
    temp3 = temp2 - i * e_x
    e_y = temp3 / norm(temp3)
    e_z = cross(e_x, e_y)
    d = norm(P2 - P1)
    j = dot(e_y, temp2)
    x = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
    y = (r1 * r1 - r3 * r3 - 2 * i * x + i * i + j * j) / (2 * j)
    temp4 = r1 * r1 - x * x - y * y
    if temp4 < 0:
        raise Exception("The three spheres do not intersect!");
    z = sqrt(temp4)
    p_12_a = P1 + x * e_x + y * e_y + z * e_z
    # There are two solutions, but we only care about one of them.
    #p_12_b = P1 + x * e_x + y * e_y - z * e_z
    # return p_12_a[0], p_12_a[1], p_12_a[2]
    return p_12_a


P1 = numpy.array([0, 0, 0])
P2 = numpy.array([1, 0, 0])
P3 = numpy.array([0, 1, 0])

print trilaterate(P1, P2, P3, 1.4, 1.1, 1.1)

# here is a bunch of "measurements"
# tuples are (D, X) where X are real (not estimated) X vectors
measurements = [
    (numpy.array([1, 2, 3]): numpy.array([4, 5, 6]))
]


def errfunc(A, B, C, L):
    square_error = 0.
    for D, realX in measurements:
        L_plus_D = L + D
        X = triliterate(A, B, C, L_plus_D[0], L_plus_D[1], L_plus_D[2])
        err = linalg.norm(X - realX)
        square_error += err ** 2
    return errfunc


def partai_vector(A, B, C, L):
    def partial(A, B, C, L, modifier):
        h = 1.0e-6
        A1, B1, C1, L1 = modifier(A, B, C, L, h)
        e1 = errfunc(A1, B1, C1, L1)
        e0 = errfunc(A, B, C, L)
        return (e1 - e0) / h

    def changex(vec, delta):
        return vec + numpy.array([delta, 0, 0])

    def changey(vec, delta):
        return vec + numpy.array([0, delta, 0])

    def changez(vec, delta):
        return vec + numpy.array([0, 0, delta])

    return numpy.array([
        partial(A, B, C, L, lambda a, b, c, l, h: changex(a, h), b, c, l),
        partial(A, B, C, L, lambda a, b, c, l, h: changey(a, h), b, c, l),
        partial(A, B, C, L, lambda a, b, c, l, h: changez(a, h), b, c, l),
        partial(A, B, C, L, lambda a, b, c, l, h: a, changex(b, h), c, l),
        partial(A, B, C, L, lambda a, b, c, l, h: a, changey(b, h), c, l),
        partial(A, B, C, L, lambda a, b, c, l, h: a, changez(b, h), c, l),
        partial(A, B, C, L, lambda a, b, c, l, h: a, b, changex(c, h), l),
        partial(A, B, C, L, lambda a, b, c, l, h: a, b, changey(c, h), l),
        partial(A, B, C, L, lambda a, b, c, l, h: a, b, changez(c, h), l),
        partial(A, B, C, L, lambda a, b, c, l, h: a, b, c, changex(l, h)),
        partial(A, B, C, L, lambda a, b, c, l, h: a, b, c, changey(l, h)),
        partial(A, B, C, L, lambda a, b, c, l, h: a, b, c, changez(l, h))
    ])
