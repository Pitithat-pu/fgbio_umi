error_exit()
{
	echo "${1}" 1>&2
	exit 1
}
## params fastq_files output_fastq
echo "Merging umi sequence files"
for fastq_file in ${fastq_files}; do
	if [ ! -f ${fastq_file} ]; then
		error_exit "Cannot find fastq file! ${fastq_file} "
  	else
		echo "${fastq_file}"
	fi
done

output_dir=$(dirname ${output_fastq})
if [ ! -d ${output_dir} ]; then
	mkdir -p ${output_dir} 
fi

echo "Merging files into ${output_fastq}"

cat `echo ${fastq_files}` > ${output_fastq}

echo "Done merging fastq files"

