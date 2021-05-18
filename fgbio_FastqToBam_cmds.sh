error_exit()
{
        echo "${1}" 1>&2
        exit 1
}
## params input_fastqs output_bam read_group sample_id library
module load java;
fgbio_jar="/abi/data/puranach/packages/fgbio-1.1.0.jar"

for file in `echo ${input_fastqs}`; do
        if [ ! -e ${file} ]; then
                error_exit "Cannot find input file! ${file} "
        fi
done
output_dir=$(dirname ${output_bam})
tmp_dir=$(mktemp -d ${output_dir}/tmp_XXXX)
fgbio="java -XX:+AggressiveOpts -jar ${fgbio_jar} --tmp-dir=${tmp_dir}"
if [ ! -d ${output_dir} ]; then
        echo "Create output directory ${output_dir}"
        mkdir -p ${output_dir}
fi
## Run fgbio Command
${fgbio} FastqToBam -i ${input_fastqs} -o ${output_bam} --read-structures +T +T +M --sort TRUE --sample ${sample_id} --library ${library} --read-group-id ${read_group}
###
rm -r ${tmp_dir}
