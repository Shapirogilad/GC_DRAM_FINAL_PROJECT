# Controller With Refresh Algorithm
After we designed a naive controller that takes care also of the refresh of the cell, but blocks the user interface, we now move on to improve the design using a refresh algorithm so the refresh will be "hidden" and occur in the backround.

The algorithm is based on having an 8 memory array, while we keep one memory empty, that memory will be called COI (copy of instance).
After a certain time that will be determined according to DRT(data retention time) we will start the refresh algorithm.
At each memory's turn we will write the memory into the COI and now the COI becomes our new memory and the refreshed memory becomes our new COI (because its values are irrelevant). We go on and do this in a cyclic manner until we have refreshed all of our cells.

We don't prevent access from the user is by exploiting the unique feature of the 4T GC eDRAM that it can perform 2 writings in one clock cycle, so we will use the first write for the user's benefit, and the seconed write for the refresh benefit. We control this by a basic 2:1 MUX where the select bit is the clock.

We implemented the controller using this algorithm described above.

## The controller's scheme

![Controller and memory array](https://drive.google.com/uc?export=view&id=16RLPw13i_YOaUDNo94ZZ_SNk2zIJmtQI "Controller and memory array with refresh algorithm")