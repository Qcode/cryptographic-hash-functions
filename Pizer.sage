from sage.schemes.elliptic_curves.ell_finite_field import is_j_supersingular
from bitarray import util

def hash(p, l, input, startingVertex = None):

    # Check the input for correctness
    if (not p.is_prime()):
        raise Exception("p should be a prime")

    field = GF(p^2)

    if (not l.is_prime()):
        raise Exception("l should be a prime")
    if (startingVertex is not None and not is_j_supersingular(field(startingVertex))):
        raise Exception("startingVertex j invariant does not correspond to a supersingular elliptic curve")

    # Determine the starting vertex as the one with the smallest j invariant
    if (startingVertex is None):
        if (is_j_supersingular(field(0))):
            startingVertex = field(0)
        elif (is_j_supersingular(field(1728))):
            startingVertex = field(1728)
        else:
            for j in field:
                if (is_j_supersingular(j)):
                    startingVertex = j
                    break

    E = EllipticCurve(field, j = startingVertex)

    # Split input into chunks of size e as described
    e = floor(log(l, 2).n())

    previousVertex = None

    for offset in range(ceil(len(input) / e)):
        # Take a chunk of the input, convert it into an integer between 0 and e

        inputChunk = input[(offset * e): (offset+1)*e]

        isogenyIndex = util.ba2int(inputChunk)

        # Calculate the isogenies of prime degree, and choose one
        isogenies = E.isogenies_prime_degree(l)

        # If our walk would cause backtracking, use the next isogeny
        if (previousVertex is not None and isogenies[isogenyIndex].codomain() == previousVertex):
            isogenyIndex = (isogenyIndex + 1) % (l + 1)

        previousVertex = E
        # E is our current vertex, set it to new vertex by using the particular isogeny
        E = isogenies[isogenyIndex].codomain()

    # Vertices are labelled by their j invariants, so return this back
    return E.j_invariant()
