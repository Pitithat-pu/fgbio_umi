error_exit()
{
        echo "${1}" 1>&2
        exit 1
}
### params input_bam output_bam
module load java;
if [ ! -e ${input_bam} ]; then
	error_exit "Cannot find input file! ${input_bam} "
fi
output_dir=$(dirname ${output_bam})
fgbio_jar="/omics/groups/OE0436/data/puranach/packages/fgbio-1.1.0.jar"
tmp_dir=$(mktemp -d ${output_dir}/tmp_XXXX)
fgbio="java -Xmx5g -XX:+AggressiveOpts -jar ${fgbio_jar} --tmp-dir=${tmp_dir}"
input_filename=$(basename $(echo ${input_bam//.bam/}))

${fgbio} GroupReadsByUmi -m 20 -s adjacency -i ${input_bam} -o ${output_bam} -f ${output_dir}/${input_filename}.umifamilysize


if [ ! -f ${output_bam} ]; then
	error_exit "Cannot produce ${output_bam}"
fi

rm -r ${tmp_dir}
