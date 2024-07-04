# Controller With Refresh Algorithm
After we designed a working controller that takes care also of the refresh of the cell, we now move on to the refresh algorithm.

The algorithm is based on having an 8 memory array, while we keep one memory empty, that memory will be called COI (copy of instance).
at each memory's turn we will write the memory into the COI and now the COI becomes our new memory and the memory becomes our new COI (because its values are irrelevant). We go on and do this in a cyclic manner until we have refreshed all of our cells.

We implemented the controller using this algorithm described above.

## The controller's scheme

![Controller and memory array](https://drive.google.com/uc?export=view&id=1lgFNRbzn7FvQf72ddQycW67c-WcnP82U "Controller and memory array with refresh algorithm")