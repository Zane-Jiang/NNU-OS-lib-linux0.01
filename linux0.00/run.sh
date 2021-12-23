#!/bin/bash
rm Image
echo 'delete Image finished '
echo "new compile ......"
make
if [ $? -eq 0 ]; then
    echo "make success"
    make clean
else 
    echo "make failed"
    exit 1
fi

bochs -f   bochs_linux00.bxrc

