error_exit()
{
        echo "${1}" 1>&2
        exit 1
}

### params mapped_bam unmapped_bam output_bam
hs37d5_PhiX="/omics/odcf/reference_data/legacy/ngs_share/assemblies/hg19_GRCh37_1000genomes/indexes/bwa/bwa06_1KGRef_Phix/hs37d5_PhiX.fa"
picard_jar="/omics/groups/OE0436/data/puranach/packages/picard.jar"
output_dir=$(dirname ${output_bam})
tmp_dir=$(mktemp -d ${output_dir}/tmp_XXXX)
module load samtools java;
for file in `echo ${mapped_bam} ${unmapped_bam} ${hs37d5_PhiX} ${picard_jar}`; do
        if [ ! -e ${file} ]; then
                error_exit "Cannot find file! ${file} "
        fi
done

java -jar ${picard_jar} MergeBamAlignment ALIGNED=${mapped_bam} UNMAPPED=${unmapped_bam} O=${output_bam} R=${hs37d5_PhiX} TMP_DIR=${tmp_dir}
rm -r ${tmp_dir}
if [ ! -f ${output_bam} ]; then
        error_exit "Cannot produce ${output_bam}"
fi
