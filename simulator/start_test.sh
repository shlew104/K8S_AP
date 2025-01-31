#!/bin/bash

echo "-----2 threads-----"                       >> resultTCP.txt
echo "[INSERT]"                                  >> resultTCP.txt
./anbo 2 i 100000                                >> resultTCP.txt
echo "[SELECT]"                                  >> resultTCP.txt
./anbo 2 s 100000                                >> resultTCP.txt
echo "[UPDATE]"                                  >> resultTCP.txt
./anbo 2 u 100000                                >> resultTCP.txt
echo "[DELETE]"                                  >> resultTCP.txt
./anbo 2 d 100000                                >> resultTCP.txt
echo "#######################################"   >> resultTCP.txt
echo "-----4 threads-----"                       >> resultTCP.txt
echo "[INSERT]"                                  >> resultTCP.txt
./anbo 4 i 100000                                >> resultTCP.txt
echo "[SELECT]"                                  >> resultTCP.txt
./anbo 4 s 100000                                >> resultTCP.txt
echo "[UPDATE]"                                  >> resultTCP.txt
./anbo 4 u 100000                                >> resultTCP.txt
echo "[DELETE]"                                  >> resultTCP.txt
./anbo 4 d 100000                                >> resultTCP.txt
echo "#######################################"   >> resultTCP.txt
echo "-----8 threads-----"                       >> resultTCP.txt
echo "[INSERT]"                                  >> resultTCP.txt
./anbo 8 i 100000                                >> resultTCP.txt
echo "[SELECT]"                                  >> resultTCP.txt
./anbo 8 s 100000                                >> resultTCP.txt
echo "[UPDATE]"                                  >> resultTCP.txt
./anbo 8 u 100000                                >> resultTCP.txt
echo "[DELETE]"                                  >> resultTCP.txt
./anbo 8 d 100000                                >> resultTCP.txt
echo "#######################################"   >> resultTCP.txt
echo "-----16threads-----"                       >> resultTCP.txt
echo "[INSERT]"                                  >> resultTCP.txt
./anbo 16 i 100000                               >> resultTCP.txt
echo "[SELECT]"                                  >> resultTCP.txt
./anbo 16 s 100000                               >> resultTCP.txt
echo "[UPDATE]"                                  >> resultTCP.txt
./anbo 16 u 100000                               >> resultTCP.txt
echo "[DELETE]"                                  >> resultTCP.txt
./anbo 16 d 100000                               >> resultTCP.txt
echo "#######################################"   >> resultTCP.txt


echo "-----2 threads-----"                       >> resultGC.txt
echo "[INSERT]"                                  >> resultGC.txt
./anbo_gc 2 i 100000                             >> resultGC.txt
echo "[SELECT]"                                  >> resultGC.txt
./anbo_gc 2 s 100000                             >> resultGC.txt
echo "[UPDATE]"                                  >> resultGC.txt
./anbo_gc 2 u 100000                             >> resultGC.txt
echo "[DELETE]"                                  >> resultGC.txt
./anbo_gc 2 d 100000                             >> resultGC.txt
echo "#######################################"   >> resultGC.txt
echo "-----4 threads-----"                       >> resultGC.txt
echo "[INSERT]"                                  >> resultGC.txt
./anbo_gc 4 i 100000                             >> resultGC.txt
echo "[SELECT]"                                  >> resultGC.txt
./anbo_gc 4 s 100000                             >> resultGC.txt
echo "[UPDATE]"                                  >> resultGC.txt
./anbo_gc 4 u 100000                             >> resultGC.txt
echo "[DELETE]"                                  >> resultGC.txt
./anbo_gc 4 d 100000                             >> resultGC.txt
echo "#######################################"   >> resultGC.txt
echo "-----8 threads-----"                       >> resultGC.txt
echo "[INSERT]"                                  >> resultGC.txt
./anbo_gc 8 i 100000                             >> resultGC.txt
echo "[SELECT]"                                  >> resultGC.txt
./anbo_gc 8 s 100000                             >> resultGC.txt
echo "[UPDATE]"                                  >> resultGC.txt
./anbo_gc 8 u 100000                             >> resultGC.txt
echo "[DELETE]"                                  >> resultGC.txt
./anbo_gc 8 d 100000                             >> resultGC.txt
echo "#######################################"   >> resultGC.txt
echo "-----16threads-----"                       >> resultGC.txt
echo "[INSERT]"                                  >> resultGC.txt
./anbo_gc 16 i 100000                            >> resultGC.txt
echo "[SELECT]"                                  >> resultGC.txt
./anbo_gc 16 s 100000                            >> resultGC.txt
echo "[UPDATE]"                                  >> resultGC.txt
./anbo_gc 16 u 100000                            >> resultGC.txt
echo "[DELETE]"                                  >> resultGC.txt
./anbo_gc 16 d 100000                            >> resultGC.txt
echo "#######################################"   >> resultGC.txt


