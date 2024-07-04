# Controller With Simple Refresh
After we designed a working controller, we modified our memory cell so after 5000 clock cycles we will "lose" our data and write X's inside the memory.

We moved on and modified our controller accordingly to handle the limited DRT(data retention time), and preform a simple refresh to all of the memories in parallel (note that we block the user from using the cell at this stage).

## The controller's scheme

![Controller and memory array](https://drive.google.com/uc?export=view&id=1lgFNRbzn7FvQf72ddQycW67c-WcnP82U "Controller and memory array with simple refresh")