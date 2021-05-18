project_dir="/icgc/dkfzlsdf/project/hipo2/hipo_K42R/sequencing/panel_sequencing/view-by-pid/"
pids_dir="/icgc/dkfzlsdf/analysis/hipo2/hipo_K42R/panel_sequencing/results_per_pid/"
PIDs="K42R-2V1J22"
PIDs="K42R-1EW2XB K42R-3N9R1T K42R-3Z79NK K42R-4BWZB3 K42R-4G4M3D K42R-4R4PZL K42R-4VJY52 K42R-4WVK8M K42R-4XDVVY K42R-4YNHUE K42R-54M9EJ K42R-73RTLN K42R-85GGU2 K42R-89QG2R K42R-8P6XML K42R-8PBD5E K42R-8RS175 K42R-97JDM1 K42R-9K8TGQ K42R-9WF5CM K42R-AVBZE4 K42R-AVFNMY K42R-AYHREY K42R-B4CB6H K42R-BX1VRP K42R-BXUWRV K42R-CNBD3M K42R-CYQ1WT K42R-D4C9FA K42R-DPTDQR K42R-DTG81X K42R-DZJ7LD K42R-E5AWW7 K42R-ECNE45 K42R-ELZ9LF K42R-EQCLRJ K42R-F7H71C K42R-FDLVP8 K42R-FS7FFB K42R-GBZG59 K42R-H2HXM9 K42R-HN7BNH K42R-JKL57T K42R-JSX6DG K42R-K6FT87 K42R-KJ3AEV K42R-KYM9GC K42R-L5CJ7G K42R-L6BYWG K42R-L6NBZL K42R-L9EU1G K42R-LFG8QH K42R-LJYM53 K42R-MDRT4W K42R-MTGLXF K42R-MU3MXJ K42R-MZ9X6N K42R-NLH3BD K42R-PFZ3QV K42R-PJLLKB K42R-PKXAA9 K42R-PUWZTW K42R-QQE1DT K42R-RFBRGC K42R-RH455C K42R-RJV78V K42R-S5AQBR K42R-SMK7DV K42R-ST6FL6 K42R-SW26NV K42R-U33ADY K42R-U3REXV K42R-UN96YU K42R-USPQ3V K42R-V5JZAK K42R-VJ94VR K42R-VV12X1 K42R-VZX2KH K42R-WVEY1H K42R-X2NC2X K42R-XFQECP K42R-YLFT6L K42R-YNK1QZ K42R-YPXF2W K42R-YYV89N K42R-Z1UWUF K42R-Z2NTCS K42R-Z7VJEE K42R-Z9G2TF K42R-ZALYJE K42R-ZGUKWW K42R-ZXBAW3"

sample_ids="plasma1-01 plasma5-01 plasma3-01 plasma2-01 plasma1-B1 plasma1-02"

fgbio_workflow_dir="/icgc/dkfzlsdf/analysis/hipo2/hipo_K42R/panel_sequencing/processing_scripts/fgbioUMI_workflow/"
merge_umi_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -W 24:00\n"
AnnotateBamWithUmis_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -W 48:00\n"
SortAndSetMateInformation_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -W 10:00\n"
GroupReadsByUmi_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -W 48:00\n"
CallMolecularConsensusReads_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -W 48:00\n"
remapping_consensus_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -W 48:00\n"

merge_umi_cmds_file="${fgbio_workflow_dir}/merge_umi_fastq_cmds.sh"
AnnotateBamWithUmis_cmds_file="${fgbio_workflow_dir}/fgbio_AnnotateBamWithUmis_cmds.sh"
SortAndSetMateInformation_cmds_file="${fgbio_workflow_dir}/fgbio_SortAndSetMateInformation_cmds.sh"
GroupReadsByUmi_cmds_file="${fgbio_workflow_dir}/fgbio_GroupReadsByUmi_cmds.sh"
CallMolecularConsensusReads_cmds_file="${fgbio_workflow_dir}/fgbio_CallMolecularConsensusReads_cmds.sh"
remapping_consensus_cmds_file="${fgbio_workflow_dir}/remapping_consensus_cmds.sh"


for pid in $PIDs; do
	pid_dir=${pids_dir}/${pid}/
	alignment_dir=${pid_dir}/alignment/
	umi_alignment_dir=${pid_dir}/alignment_umi/
	mkdir -p ${umi_alignment_dir}
	for sample_id in ${sample_ids}; do
		sample_bam=$(find ${alignment_dir} -name "${sample_id}*_*mdup.bam")
		if [  -z ${sample_bam} ]; then
			continue
		else
			echo "Found sample bam : $(basename ${sample_bam})"
			bam_filename=$(basename ${sample_bam})
			sample_id=$(echo ${bam_filename} | cut -f1 -d"_")
			bam_filename_noext=$(echo ${bam_filename//.bam/})
			
			sequence_dir=${project_dir}/${pid}/${sample_id}/paired/run*/sequence/
			umi_fastqs=$(find ${sequence_dir} -name *I1.fastq.gz)
			#echo "Found UMI fastq files"
			

### Merged multiple umi files into one fastq file
			merged_umi_fastq=${umi_alignment_dir}/${bam_filename}_merged_umi.fastq.gz
			merge_umi_params="umi_fastqs=\"$(echo ${umi_fastqs})\";output_fastq=${merged_umi_fastq}"
###
### Annotate bam file with umis sequence
			AnnotateBamWithUmis_bam=${umi_alignment_dir}/${bam_filename_noext}_AnnotatedBamWithUMIs.bam
			AnnotateBamWithUmis_params="input_bam=${sample_bam};umi_fastq=${merged_umi_fastq};output_bam=${AnnotateBamWithUmis_bam};"
###

### Sort bam by readname and include mate-read information e.g. mapping cigar and mapping quality
			SortAndSetMateInformation_bam=${umi_alignment_dir}/${bam_filename_noext}_AnnotatedBamWithUMIs_sorted_addmateinfo.bam
			SortAndSetMateInformation_params="input_bam=${AnnotateBamWithUmis_bam};output_bam=${SortAndSetMateInformation_bam}"
###

### Group read by the annotated umi sequence
			GroupReadsByUmi_bam=${umi_alignment_dir}/${bam_filename_noext}_AnnotatedBamWithUMIs_sorted_addmateinfo_GroupByUMI.bam
			GroupReadsByUmi_params="input_bam=${SortAndSetMateInformation_bam};output_bam=${GroupReadsByUmi_bam}"
###

### Call consensus sequence from read comming from same umi group
			CallMolecularConsensusReads_bam=${umi_alignment_dir}/${bam_filename_noext}_AnnotatedBamWithUMIs_sorted_addmateinfo_GroupByUMI_CallConsensus.bam
			CallMolecularConsensusReads_params="input_bam=${GroupReadsByUmi_bam};output_bam=${CallMolecularConsensusReads_bam}"
###

### Remapping the sequence with bwa
			Remapping_bam=${umi_alignment_dir}/${bam_filename_noext}_AnnotatedBamWithUMIs_sorted_addmateinfo_GroupByUMI_CallConsensus_realigned.bam
			Remapping_params="input_bam=${CallMolecularConsensusReads_bam};output_bam=${Remapping_bam}"
###			
			#echo ${merge_umi_CMD}
			bsubExecutionStore=${umi_alignment_dir}/bsubExecutionStore
			echo "Create bsubExecutionStore directory ${bsubExecutionStore}"; mkdir -p ${umi_alignment_dir}/bsubExecutionStore
			echo -e "${merge_umi_bsub_header}${merge_umi_params}\n`cat ${merge_umi_cmds_file}`" > ${bsubExecutionStore}/merge_umi_fastq.sh
			echo -e "${AnnotateBamWithUmis_bsub_header}${AnnotateBamWithUmis_params}\n`cat ${AnnotateBamWithUmis_cmds_file}`" > ${bsubExecutionStore}/fgbio_AnnotateBamWithUmis.sh
			echo -e "${SortAndSetMateInformation_bsub_header}${SortAndSetMateInformation_params}\n`cat ${SortAndSetMateInformation_cmds_file}`" > ${bsubExecutionStore}/fgbio_SortAndSetMateInformation.sh
			echo -e "${GroupReadsByUmi_bsub_header}${GroupReadsByUmi_params}\n`cat ${GroupReadsByUmi_cmds_file}`" > ${bsubExecutionStore}/fgbio_GroupReadsByUmi.sh
			echo -e "${CallMolecularConsensusReads_bsub_header}${CallMolecularConsensusReads_params}\n`cat ${CallMolecularConsensusReads_cmds_file}`" > ${bsubExecutionStore}/fgbio_CallMolecularConsensusReads.sh
			echo -e "${remapping_consensus_bsub_header}${Remapping_params}\n`cat ${remapping_consensus_cmds_file}`" > ${bsubExecutionStore}/remapping_consensus.sh
			chmod 764 ${bsubExecutionStore}/merge_umi_fastq.sh ${bsubExecutionStore}/fgbio_AnnotateBamWithUmis.sh ${bsubExecutionStore}/fgbio_SortAndSetMateInformation.sh ${bsubExecutionStore}/fgbio_GroupReadsByUmi.sh ${bsubExecutionStore}/fgbio_CallMolecularConsensusReads.sh ${bsubExecutionStore}/remapping_consensus.sh
			#bsub ${merge_umi_CMD} -J merge_umi_${sample_id}
			#echo ${AnnotateBamWithUmis_CMD}
			#echo ${SortAndSetMateInformation_CMD}
			#echo ${GroupReadsByUmi_CMD}
			#echo ${CallMolecularConsensusReads_CMD}
			#echo ${Remapping_CMD}
			echo "Create ${bsubExecutionStore}/bsubCall.sh"
			bsubcmd_merge_umi="merge_umi_fastq_jobid=\$(bsub -J merge_umi_${sample_id}_${pid} < ${bsubExecutionStore}/merge_umi_fastq.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"

			bsubcmd_AnnotateBamWithUmis="AnnotateBamWithUmis_jobid=\$(bsub -J AnnotateBamWithUmis_${sample_id}_${pid} -w \"done(\${merge_umi_fastq_jobid})\" < ${bsubExecutionStore}/fgbio_AnnotateBamWithUmis.sh |  awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"
			
			bsubcmd_SortAndSetMateInformation="SortAndSetMateInformation_jobid=\$(bsub -J SortAndSetMateInformation_${sample_id}_${pid} -w \"done(\${AnnotateBamWithUmis_jobid})\" < ${bsubExecutionStore}/fgbio_SortAndSetMateInformation.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"
			bsubcmd_GroupReadsByUmi="GroupReadsByUmi_jobid=\$(bsub -J GroupReadsByUmi_${sample_id}_${pid} -w \"done(\${SortAndSetMateInformation_jobid})\" < ${bsubExecutionStore}/fgbio_GroupReadsByUmi.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"

			bsubcmd_CallMolecularConsensusReads="CallMolecularConsensusReads_jobid=\$(bsub -J CallMolecularConsensusReads_${sample_id}_${pid} -w \"done(\${GroupReadsByUmi_jobid})\" < ${bsubExecutionStore}/fgbio_CallMolecularConsensusReads.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"

			bsubcmd_remapping_consensus="remapping_consensus_jobid=\$(bsub -J remapping_consensus_${sample_id}_${pid} -w \"done(\${CallMolecularConsensusReads_jobid})\" < ${bsubExecutionStore}/remapping_consensus.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}')"

			echo -e "${bsubcmd_merge_umi}\n${bsubcmd_AnnotateBamWithUmis}\n${bsubcmd_SortAndSetMateInformation}\n${bsubcmd_GroupReadsByUmi}\n${bsubcmd_CallMolecularConsensusReads}\n${bsubcmd_remapping_consensus}" > ${bsubExecutionStore}/bsubCall.sh
			chmod 764 ${bsubExecutionStore}/bsubCall.sh
			echo "Execute bsub commands ${bsubExecutionStore}/bsubCall.sh"
			${bsubExecutionStore}/bsubCall.sh
		fi
	done

done
