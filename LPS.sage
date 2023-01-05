from bitarray import util

# p is a small prime, l is a large prime
# Assume input is a bitarray, startingVertex is a 2 by 2 matrix over GF(p) with determinant 1

def hash(p, l, input, startingVertex = None):
    # Check the input for correctness
    if (not p.is_prime()):
        raise Exception("p should be a prime")

    if (l % 4 != 1):
        raise Exception("l should be congruent to 1 mod 4")

    if (not l.is_prime()):
        raise Exception("l should be a prime")

    # Sage uses kronecker in place of the legendre symbol
    if (kronecker(l, p) != 1):
        raise Exception("l should be a quadratic residue mod p")

    field = GF(p)

    M = MatrixSpace(field, 2, 2)

    gSolutions = []

    # The paper describes a set S of elements g, such that g0^2 + g1^2 + g2^2 + g3^2 = l
    # We can find these via exhaustive search, quickly, since l is assumed to be small

    # Lower bound is between -sqrt(l) and sqrt(l)
    # Make sure lowerBound is always even, so we can advance by 2 for g1...g3
    lowerBound = -ceil(sqrt(l)) - (ceil(sqrt(l)) % 2)
    upperBound = ceil(sqrt(l))

    # We search for solutions with g0 > 0 and odd, and g1-g3 even
    for g0 in range(1, l, 2):
        for g1 in range(lowerBound, upperBound, 2):
            for g2 in range(lowerBound, upperBound, 2):
                for g3 in range(lowerBound, upperBound, 2):
                    if (g0 ^ 2 + g1 ^ 2 + g2 ^ 2 + g3 ^ 2 == l):
                        gSolutions.append(
                            (field(g0), field(g1), field(g2), field(g3)))

    for index, solution in enumerate(gSolutions):
        # We want to use the canonical representation.
        # We allow the equivalence relation A = -A
        # And use the one with the smallest ordering
        otherSolution = (-solution[0], -solution[1], -
                         solution[2], -solution[3])

        if (solution > otherSolution):
            gSolutions[index] = otherSolution

    # Now that we have the solutions to this equation, we can calculate the actual matrices g
    gMatrices = []
    gInverses = []
    for solution in gSolutions:
        g0 = solution[0]
        g1 = solution[1]
        g2 = solution[2]
        g3 = solution[3]

        i = field(-1).sqrt()

        M = MatrixSpace(field, 2, 2)
        g = M([g0 + i * g1, g2 + i * g3, -g2 + i * g3, g0 - i * g1]) / field(l).sqrt()
        gMatrices.append(g)
        # Also keep track of the inverses, so that we can avoid backtracking
        gInverses.append(g.inverse())

    currentVertex = startingVertex if startingVertex is not None else M([1, 0, 0, 1])

    # Split input into chunks of size e as described in section 3
    e = floor(log(l, 2).n())

    lastGIndex = None

    for offset in range(ceil(len(input) / e)):
        # Take a chunk of the input, convert it into an integer between 0 and e
        inputChunk = input[(offset * e): (offset+1)*e]

        gChoiceIndex = util.ba2int(inputChunk)

        # If we would immediattely backtrack, then adjust the choice of g
        if (lastGIndex is not None and gMatrices[gChoiceIndex] == gInverses[lastGIndex]):
            gChoiceIndex = (gChoiceIndex + 1) % (l + 1)

        # We take the edge associated with the element g
        currentVertex = currentVertex * gMatrices[gChoiceIndex]
        lastGIndex = gChoiceIndex

    return currentVertex
