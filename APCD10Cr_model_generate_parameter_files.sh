#! /bin/bash
# Copyright 2021 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/APCD10Cr_Carson_2022
#
# generateParameterFiles.sh is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# generateParameterFiles.sh is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.


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
