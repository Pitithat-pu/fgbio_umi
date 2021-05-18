error_exit()
{
        echo "${1}" 1>&2
        exit 1
}

### params input_bams output_bam
#hs37d5_PhiX="/icgc/ngs_share/assemblies/hg19_GRCh37_1000genomes/indexes/bwa/bwa06_1KGRef_Phix/hs37d5_PhiX.fa"
picard_jar="/abi/data/puranach/packages/picard.jar"
output_dir=$(dirname ${output_bam})
tmp_dir=$(mktemp -d ${output_dir}/tmp_XXXX)
module load samtools java;
I_params=""
for input_bam in ${input_bams}; do
	if [ ! -e ${input_bam} ]; then
                error_exit "Cannot find file! ${input_bam} "
        fi
	I_params="${I_params}I=${input_bam} "
done

java -jar ${picard_jar} MergeSamFiles ${I_params} O=${output_bam} SO=queryname USE_THREADING=true TMP_DIR=${tmp_dir}
rm -r ${tmp_dir}
if [ ! -f ${output_bam} ]; then
        error_exit "Cannot produce ${output_bam}"
fi
