error_exit()
{
        echo "${1}" 1>&2
        exit 1
}
### params input_bam output_bam
hs37d5_PhiX="/icgc/ngs_share/assemblies/hg19_GRCh37_1000genomes/indexes/bwa/bwa06_1KGRef_Phix/hs37d5_PhiX.fa"
picard_jar="/abi/data/puranach/packages/picard.jar"
module load bwa java picard samtools;

for file in `echo ${input_bam} ${hs37d5_PhiX} ${picard_jar}`; do
        if [ ! -e ${file} ]; then
                error_exit "Cannot find file! ${file} "
        fi
done


java -jar -Xmx5G ${picard_jar} SamToFastq I=${input_bam} F=/dev/stdout INTERLEAVE=true \
| bwa mem -p -M -t 20 ${hs37d5_PhiX} /dev/stdin \
| samtools view -bSu - | samtools sort -o ${output_bam}

if [ ! -f ${output_bam} ]; then
        error_exit "Cannot produce ${output_bam}"
fi

samtools index ${output_bam}

