error_exit()
{
        echo "${1}" 1>&2
        exit 1
}

##params input_bam umi_fastq output_bam
module load java;
fgbio_jar="/abi/data/puranach/packages/fgbio-1.1.0.jar"

for file in `echo ${input_bam} ${umi_fastq}`; do
	if [ ! -e ${file} ]; then
		error_exit "Cannot find input file! ${file} "
	fi	
done
output_dir=$(dirname ${output_bam})
tmp_dir=$(mktemp -d ${output_dir}/tmp_XXXX)
fgbio="java -Xmx10g -XX:+AggressiveOpts -jar ${fgbio_jar} --tmp-dir=${tmp_dir}"
if [ ! -d ${output_dir} ]; then
	echo "Create output directory ${output_dir}"
	mkdir -p ${output_dir}
fi

## Run fgbio Command
${fgbio} AnnotateBamWithUmis -i ${input_bam}  -f ${umi_fastq} -o ${output_bam}
###
rm -r ${tmp_dir}
