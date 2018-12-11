
# export READS_FQ=../pacbio/m160526_170733_42274_c101014002550000001823231410211647_s1_p0.filtered.subreads.fastq

export READS_FQ=../pacbio/Fastq/m160426_225135_00116_c100976532550000001823226708101600_s1_p0.filtered.subreads.fastq.gz
export SQUEAKR_DIR=../squeakr
export READ_SQ_DIR=./
export K=6
export S=20


make_ref_cqf() {

	${SQUEAKR_DIR}/squeakr-count -f -k $K -s $S -t 1 -o ./ ../data/monomers/d0.fq \
	&& mv d0.fq.ser d0.fq.K$K.S$S.ser
	# echo "got d0.fq.K$K.S$S.ser"
}

MONS_CQF=./d0.fq.K$K.S$S.ser

# if [[ -e CQF_IP.K$K.S$S.dat ]]; then echo "Warning: overwriting CQF_IP.K$K.S$S.dat. Aborting."; fi

# ${READ_SQ_DIR}/squeakr-count -f -k $K -s $S -r ${MONS_CQF} -t 1 -o . ./test.fastq
# wc -l ${READS_FQ}

## This is the call for read-squeakr
# -- for plain fq
# ${READ_SQ_DIR}/squeakr-count -f -k $K -s $S -r ${MONS_CQF} -t 1 -o . ${READS_FQ}
# -- for fq.gz

${READ_SQ_DIR}/squeakr-count -g -k $K -s $S -r ${MONS_CQF} -t 1 -o . ${READS_FQ}

exit

cat ${READS_FQ} | head -n 40000 | while read line; do

	# get four lines at a time
	NAME=${line#@}; echo $line > a_read.fq
	read line; READLEN=${#line}; echo $line >> a_read.fq
	for i in {1..2}; do read line; echo $line >> a_read.fq; done

	# calc CQF inner product
	${SQUEAKR_DIR}/squeakr-count -f -k $K -s $S -t 1 -o . a_read.fq  2>&1 > /dev/null
	IP_RAW=$( ${SQUEAKR_DIR}/squeakr-inner-prod -a $MONS_CQF -b a_read.fq.ser 2>&1 | grep "Inner product" )
	IP_RAW=${IP_RAW#Inner product: }
	IP_NORM=$( echo "scale=4; $IP_RAW / $READLEN" | bc -l )

	echo -e "$NAME\t$READLEN\t$IP_RAW\t$IP_NORM" >> CQF_IP.K$K.S$S.dat
done

rm a_read.fq a_read.fq.ser
