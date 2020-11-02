#!/bin/sh
#######Path Defination###############
User_DIR=$(cd "$(dirname "$0")";pwd)

OP_LIST_DIR=${User_DIR}/FF_STATION

if [ ! -e ${OP_LIST_DIR} ]; then
  mkdir -p ${OP_LIST_DIR}
fi

TPG=0 #=0:LFSR,=1:ATPG
TEST_VEC=10 #0 00 # Number of Test patterns
TOOLMODE=3 #=1:Normal Scan test, =2:Multi-cycle Test, =3: Multi-cycle test with Seq OB, =4:Toggle Gate TPI

OBRATE=0.2 #Observation Rate
SKIPCYCLES=0

ulimit -s unlimited

rm -f *.dat
for CIRCUIT in s9234 #s13207 s15850 s38417 s38584 #b14s.osaka b15s.osaka b20s.osaka  #s9234 s13207 s15850 s38417 s38584  b14s.osaka b15s.osaka b20s.osaka #b20s.osaka #s15850 s35932 s38584 s38417 #s13207 #s1488 s5378 s9234 #s13207 #s9234 #s15850 s38417 #s38584 #b04s.osaka b05s.osaka b06.osaka b14s.osaka b15s.osaka b20s.osaka

do
rm -f lfsr*.dat ATPG.dat

  ln -s ./circuit/$CIRCUIT
  ln -s ./tpg/lfsr.dat

	if [ "$TPG" = "0" ];
	then
		rm -f ${CIRCUIT}_lfsr_pi.dat
		./tpg/lfsr $CIRCUIT $TEST_VEC ${CIRCUIT}_lfsr_pi.dat
		ln -s tmp.test ${CIRCUIT}_lfsr_pi.dat
	else
 		 ln -s ./ATPG/SA/Com1Test/"$CIRCUIT".tests ATPG.dat
	fi

if [ ! -e ${OP_LIST_DIR}/${CIRCUIT} ]; then
  mkdir -p ${OP_LIST_DIR}/${CIRCUIT}
fi

	cnt1=0
	for ff_sta_file in  ${OP_LIST_DIR}/${CIRCUIT}/TOPSIS
	do
		if [ -e $ff_sta_file ];
		then
 		 echo === OB_STATION INFO of $ff_sta_file is FOUND, CONTINUE THE FAULT SIM PROCESS===
		else
 		 echo === NO OB_STATION INFO, PLEASE BACK TO FF_SELECTION PROCESS to Generate $ff_sta_file===
			exit
		fi

		ln -s $ff_sta_file ff_station_$cnt1.dat
		let cnt1=${cnt1}+1
	done

	for CAPTURE in 5 # 2 3 4 5  #15 #1 #20 #1 5 10 15 #20 #15 #20 #2 #20 #2 3 4 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
		do
	 time ./lbistsim $CIRCUIT $TOOLMODE $TPG $CAPTURE $SKIPCYCLES $OBRATE $cnt1 #>> Switch_ctr.txt
	done

    if [ -e fault_list.dat ];
      then
      mv fault_list.dat "$CIRCUIT"_fault_list.dat
      if [ ! -e ./fault_list ];
        then
        mkdir fault_list
      fi
      mv "$CIRCUIT"_fault_list.dat ./fault_list
    fi
#if exist fault list file -end-
#rm -f #ff_station* tgl_* nfs*
rm -f $CIRCUIT lfsr.dat *~ tmp*  ff_station.dat ATPG.dat *lfsr_pi.dat
done
