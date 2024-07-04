# Refresh Algorithm for eDRAM 
Design and implementation of a memory controller capable of 
refreshing DRAM cells without interrupting user access to the 
memory.

## Road Map
### First Milestone
* Getting familiar with the 4T GC-eDRAM cell
* Designing a simple controller to control an array of 8 simple memories

### Seconed Milestone
* Modify the memories so after a limited DRT(data retention time) the data will be lost
* Modify the controller to support a refresh method so we won't lose any data

### Third Milestone
* Implement a refresh cyclic algorithm so the refresh will occur in a hidden way so it won't affect the user

### Fourth Milestone
* Verify the design by generating tests at the tb

### Fifth Milestone
* Synthesize the design

### Six Milestone
* Writing an IEEE standerd article the concludes all the work that we have done and sumerizes the results

## Toolchain:
* System Verilog for simulation
* Genus for synthesis