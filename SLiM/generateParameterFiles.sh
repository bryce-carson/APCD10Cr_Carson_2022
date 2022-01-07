#! /bin/bash
PARAM=1
for parameterSet in $@; do
for R in `cut -f 1 ${parameterSet} | tail -n +2`; do
for muAP in `cut -f 2 ${parameterSet} | tail -n +2`; do
for N in `cut -f 3 ${parameterSet} | tail -n +2`; do
for m in `cut -f 4 ${parameterSet} | tail -n +2`; do
for phi in `cut -f 5 ${parameterSet} | tail -n +2`; do
for muCD in `cut -f 6 ${parameterSet} | tail -n +2`; do
for sAP in `cut -f 7 ${parameterSet} | tail -n +2`; do
for r in `cut -f 8 ${parameterSet} | tail -n +2`; do
for sCD in `cut -f 9 ${parameterSet} | tail -n +2`; do
for outputEveryNGenerations in `cut -f 10 ${1} | tail -n +2`; do
echo "-d R=${R}
-d r=${r}
-d N=${N}
-d m=${m}
-d phi=${phi}
-d sCD=${sCD}
-d sAP=${sAP}
-d muAP=${muAP}
-d muCD=${muCD}
-d REP=0
-d outputEveryNGenerations=${outputEveryNGenerations}" > params_${PARAM}
PARAM=$(( $PARAM + 1 ))
done; done; done; done; done; done; done; done; done; done; done #End the large loop.
