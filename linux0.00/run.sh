#!/bin/bash
rm Image
echo 'delete Image finished '
echo "new compile ......"
make
make clean
echo"compile finished !"
bochs -f bochs_linux00.bxrc

