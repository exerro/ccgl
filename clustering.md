
# Introduction

Given an RGB-based texture, the task is to reduce it to a constant P-colour palette.
RGB textures hold R, G, and B values [0, 1], with effectively 256 discrete values.

## Example cases

> $B refers to buffer size in total pixels

* Pure noise      = min($B, 256 * 256 * 256)
	- no spatial coherence
* Linear gradient = min($B, sqrt(256 * 256 * 3))
	- linear spatial coherence
* Blocks          ~ 10
	- rectangular spatial coherence
* Linear lighting = min($B, 256 * 256 * 256)
	- local approximately linear spatial coherence

Given the above cases, there is a necessity to
* reduce large colour spaces
* preserve linear relationships between colours
* preserve low distinct colour counts

# Algorithm

let P = the number of colours to reduce the set to.

For a colour count less than or equal to P, it is trivial.
Generate metadata and return, with the colours unaltered.
For greater colour counts;
* Sort colours in Z, then Y, then X
* let G = { (0, N) }
* for each G, divide in Z, then Y, then X
* remove any groups (a, b) where a == b
* stop when the number of groups exceeds some constant

Splitting a group in some dimension D involves finding a division factor Dd
to minimise `\sum{(p[D] - Dd) ^ 2}` and then partitioning members of the group
into two new groups based on `p[D] < Dd`

A unit group (a, b) s.t. (a == b - 1) cannot be split.

Once the divisions have occurred, generate centroids and weights for each group.
