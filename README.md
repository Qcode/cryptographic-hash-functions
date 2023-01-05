My CO 685 project was to implement the hash functions described in [“Cryptographic Hash Functions from expander graphs”](https://eprint.iacr.org/2006/021.pdf) by Charles, Goren, and Lauter. I did this in Sage, since there was up to this point no such Sage implementation.

In terms of dependencies, the project relies on the Sage math libraries, and the python module `bitarray` (for providing input). The `bitarray` library can be installed by running:

`sage -pip install bitarray`

The first file included is Pizer.sage. This file implements the hashing scheme defined in section 4 of the aforementioned paper. We can load this within the Sage interactive prompt (assuming that we’re running it in the same directory as the Pizer.sage file) with the command:

`load("Pizer.sage")`

This gives us the function: `hash(p, l, input, startingVertex)`. `p` and `l` must both be primes. `input` is expected to be of type `bitarray`. Finally, `startingVertex` is an optional argument, which is the $j$-invariant of a supersingular elliptic curve defined over $\mathbb{F}_p^2$ . Recall that the hash function is the result of a walk on the expander graph. If `startingVertex` is omitted we instead start our walk on a supersingular elliptic curve with the smallest $j$-invariant.

An example invocation might be something like:

```Python
load("Pizer.sage")
from bitarray import bitarray
p = 102126964395452893518137496086575681509488172603806003483012675645629394921357
hash(p, 2, bitarray('110110101101111'))
```

`p` here is a 256-bit prime, `l` is chosen to be a relatively small prime for efficient computation, and one can modify the bits in the `bitarray` to see the hash function’s output change.

We may wish to use a larger input for timings with longer walks. In which case, we can place our input in a file called `input.txt`, and do something like:

```Python
load("Pizer.sage")
from bitarray import bitarray
p = 102126964395452893518137496086575681509488172603806003483012675645629394921357
input = bitarray()
input.fromfile(open("input.txt", 'rb'))
hash(p, 2, input)
```

The second file included is LPS.sage. This file implements the hashing scheme defined in section 7 of the paper. We can load it using

`load("LPS.sage")`

Similarly, we are given the function `hash(p, l, input, startingVertex)`. This requires that `p` and `l` are both primes, and furthermore, that `l` is a quadratic residue mod `p`, and that $l \equiv 1 \mod 4$.

`startingVertex` is an optional argument, which is a member of $\text{PSL}(2,\mathbb{F}_p)$ represented in the form of a 2 x 2 matrix over $\mathbb{F}_p$ with determinant 1. If it omitted, we use the identity matrix as our starting vertex. An example might look like:
```Python
load("LPS.sage")
from bitarray import bitarray
p = 337544925902049592895747849563103085161
hash(p, 5, bitarray("101101110001101011"))
```

In this example, `p` is a 128 bit prime, `l` is chosen to be 5 (once again, a small prime), and we can modify the bits in the bitarray to see the different outputs of the hash function.

Similarly, we can use the bitarray fromfile command to load larger bitarrays as input. For example, I used [this website](https://pinetools.com/random-string-generator) to generate a random 250000 character string (which leads to 2 million bit input, and so a walk of length 1 million). I then ran:
```python
load("LPS.sage")
from bitarray import bitarray
p = 337544925902049592895747849563103085161
input = bitarray()
input.fromfile(open("input.txt", 'rb'))
time hash(p, 5, input)
```

This yielded a result of
```
[263322724355686031977978181280147313300 31365369563981276403739562779009592238]
[ 18066152949563575780554423601158573199 313594944614355606514721563738754183689]
```
after 3.94s on a MacBook Pro with 16GB RAM and an Apple M1 chip. The code is annotated with comments to describe the steps of each function.
