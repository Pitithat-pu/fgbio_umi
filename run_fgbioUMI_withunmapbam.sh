project_dir="/icgc/dkfzlsdf/project/OE0290/pediatric_tumor/sequencing/panel_sequencing/view-by-pid/"
pids_dir="/icgc/dkfzlsdf/analysis/OE0290_projects/pediatric_tumor/panel_sequencing/results_per_pid/"


PIDs="OE0290-PED_1LB-003 OE0290-PED_1LB-006 OE0290-PED_1LB-011 OE0290-PED_1LB-012 OE0290-PED_1LB-013 OE0290-PED_1LB-014 OE0290-PED_1LB-015 OE0290-PED_1LB-016 OE0290-PED_1LB-017 OE0290-PED_1LB-018 OE0290-PED_1LB-019 OE0290-PED_1LB-020 OE0290-PED_1LB-022 OE0290-PED_1LB-023 OE0290-PED_1LB-025 OE0290-PED_1LB-026 OE0290-PED_1LB-027 OE0290-PED_1LB-028 OE0290-PED_1LB-030 OE0290-PED_1LB-031 OE0290-PED_1LB-033"
PIDs="OE0290-PED_0LB-040 OE0290-PED_0LB-041 OE0290-PED_0LB-042 OE0290-PED_0LB-043 OE0290-PED_0LB-044"

PIDs="OE0290-PED_4LB-002 OE0290-PED_4LB-003 OE0290-PED_4LB-004 OE0290-PED_4LB-005 OE0290-PED_4LB-006 OE0290-PED_4LB-007 OE0290-PED_4LB-008 OE0290-PED_4LB-009"

fgbio_workflow_dir="/icgc/dkfzlsdf/analysis/OE0290_projects/pediatric_tumor/panel_sequencing/processing_scripts/fgbioUMI_workflow/"

FastqToBam_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -R \"rusage[mem=10GB]\"\n"
MergeSamFiles_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -R \"rusage[mem=10GB]\"\n"
MergeBamAlignment_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -R \"rusage[mem=10GB]\"\n"
GroupReadsByUmi_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -R \"rusage[mem=10GB]\"\n"
CallMolecularConsensusReads_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -R \"rusage[mem=10GB]\"\n"
remapping_consensus_bsub_header="#!/bin/bash\n#BSUB -q verylong\n#BSUB -R \"rusage[mem=50GB]\"\n"



FastqToBam_cmds_file="${fgbio_workflow_dir}/fgbio_FastqToBam_cmds.sh"
MergeSamFiles_cmds_file="${fgbio_workflow_dir}/picard_MergeSamFiles_cmds.sh"
MergeBamAlignment_cmds_file="${fgbio_workflow_dir}/picard_MergeBamAlignment_cmds.sh"
GroupReadsByUmi_cmds_file="${fgbio_workflow_dir}/fgbio_GroupReadsByUmi_cmds.sh"
CallMolecularConsensusReads_cmds_file="${fgbio_workflow_dir}/fgbio_CallMolecularConsensusReads_cmds.sh"
remapping_consensus_cmds_file="${fgbio_workflow_dir}/remapping_consensus_cmds.sh"


for pid in $PIDs; do
	pid_dir=${pids_dir}/${pid}/
	alignment_dir=${pid_dir}/alignment/
	umi_alignment_dir=${pid_dir}/alignment_umi/
	mkdir -p ${umi_alignment_dir}
	sample_bams=$(find ${alignment_dir} -name "*merged.mdup.bam")
	for sample_bam in ${sample_bams}; do
		#sample_bam=$(find ${alignment_dir} -name "${sample_id}*_*mdup.bam")
		bam_filename=$(basename ${sample_bam})
                sample_id=$(echo ${bam_filename} | cut -f1 -d"_")
                echo "Found sample bam : ${bam_filename}"
		#if [  -z ${sample_bam} ]; then
		#	continue
		#else
			#echo "Found sample bam : $(basename ${sample_bam})"
			bsubExecutionStore=${umi_alignment_dir}/bsubExecutionStore_${sample_id}_${pid}/
			echo "Create bsubExecutionStore directory ${bsubExecutionStore}"; mkdir -p ${bsubExecutionStore}
			#bam_filename=$(basename ${sample_bam})
			#sample_id=$(echo ${bam_filename} | cut -f1 -d"_")
			bam_filename_noext=$(echo ${bam_filename//.bam/})
			
			sequence_dirs=`find ${project_dir}/${pid}/${sample_id}/paired/run*/sequence -type d`
			sample_ubam_dir=${umi_alignment_dir}/merged_ubam/${sample_id}_${pid}/
			[ ! -d ${sample_ubam_dir} ] || rm -r ${sample_ubam_dir}
			mkdir -p ${sample_ubam_dir}
			
                        echo -e "${FastqToBam_bsub_header}\n" >  ${bsubExecutionStore}/fgbio_FastqToBam.sh
                        umi_fastqs=$(find ${sequence_dirs} -name *I1.fastq.gz)
			FastqToBam_bams=""
                        for umi_fastq in ${umi_fastqs}; do
				R1_fastq=`find ${sequence_dirs} -name $(basename ${umi_fastq} | sed 's/_I1/_R1/')`
				R2_fastq=`find ${sequence_dirs} -name $(basename ${umi_fastq} | sed 's/_I1/_R2/')`
### Create unmapped bam with umi sequence (RX tag)
                                fastq_id=$(echo `basename ${R1_fastq} | sed 's/_R1.fastq.gz//'`)
                                runid=$(echo ${R1_fastq} | grep -oP 'run[0-9].*?/' | sed 's/\///')
                                fastq_prefix=$(basename $(echo ${R1_fastq%_R1.fastq.gz}))
                                read_group=${runid}_${fastq_prefix}
                                FastqToBam_bam=${sample_ubam_dir}/${sample_id}_${pid}_${fastq_id}_umap.bam

                                FastqToBam_params="input_fastqs=\"$(echo ${R1_fastq} ${R2_fastq} ${umi_fastq})\";output_bam=${FastqToBam_bam};sample_id=sample_${sample_id}_${pid};library=${sample_id}_${pid};read_group=${read_group}"
                                echo -e "${FastqToBam_params}\n`cat ${FastqToBam_cmds_file}`\n" >>  ${bsubExecutionStore}/fgbio_FastqToBam.sh
				FastqToBam_bams="${FastqToBam_bams}${FastqToBam_bam} "
                        done
			
###
			#R1_fastqs=$(find ${sequence_dirs} -name *R1.fastq.gz)
			#R2_fastqs=$(find ${sequence_dirs} -name *R2.fastq.gz)
			#echo "Found UMI fastq files"
			

### Merge unmaped bam files from each run
			#FastqToBam_bams=$(find ${sample_ubam_dir} -name ${sample_id}_${pid}_*_umap.bam)
			MergeSamFiles_bam=${umi_alignment_dir}/${bam_filename_noext}_umap_merged.bam
			MergeSamFiles_params="input_bams=\"$(echo ${FastqToBam_bams})\";output_bam=${MergeSamFiles_bam}"

###

### Merge information (including RX tag) from unmapped bam to ODCF mapped bam           
                        MergeBamAlignment_bam=${umi_alignment_dir}/${bam_filename_noext}_umitaged.bam
                        MergeBamAlignment_params="mapped_bam=${sample_bam};unmapped_bam=${MergeSamFiles_bam};output_bam=${MergeBamAlignment_bam}"

###

### Group read by the annotated umi sequence
			GroupReadsByUmi_bam=${umi_alignment_dir}/${bam_filename_noext}_groupbyUMI.bam
			GroupReadsByUmi_params="input_bam=${MergeBamAlignment_bam};output_bam=${GroupReadsByUmi_bam}"
###

### Call consensus sequence from read comming from same umi group
			CallMolecularConsensusReads_bam=${umi_alignment_dir}/${bam_filename_noext}_groupbyUMI_callconsensus.bam
			CallMolecularConsensusReads_params="input_bam=${GroupReadsByUmi_bam};output_bam=${CallMolecularConsensusReads_bam}"
###

### Remapping the sequence with bwa
			Remapping_bam=${umi_alignment_dir}/${bam_filename_noext}_groupbyUMI_callConsensus_realigned.bam
			Remapping_params="input_bam=${CallMolecularConsensusReads_bam};output_bam=${Remapping_bam}"
###
			#echo ${merge_umi_CMD}

			echo -e "${MergeSamFiles_bsub_header}${MergeSamFiles_params}\n`cat ${MergeSamFiles_cmds_file}`" > ${bsubExecutionStore}/picard_MergeSamFiles.sh
			echo -e "${MergeBamAlignment_bsub_header}${MergeBamAlignment_params}\n`cat ${MergeBamAlignment_cmds_file}`" > ${bsubExecutionStore}/picard_MergeBamAlignment.sh
			echo -e "${GroupReadsByUmi_bsub_header}${GroupReadsByUmi_params}\n`cat ${GroupReadsByUmi_cmds_file}`" > ${bsubExecutionStore}/fgbio_GroupReadsByUmi.sh
			echo -e "${CallMolecularConsensusReads_bsub_header}${CallMolecularConsensusReads_params}\n`cat ${CallMolecularConsensusReads_cmds_file}`" > ${bsubExecutionStore}/fgbio_CallMolecularConsensusReads.sh
			echo -e "${remapping_consensus_bsub_header}${Remapping_params}\n`cat ${remapping_consensus_cmds_file}`" > ${bsubExecutionStore}/remapping_consensus.sh
			


			bsubExecutionlog=${bsubExecutionStore}/bsubExecutionlog/${sample_id}_${pid}/
			echo "Create bsubExecutionlog directory ${bsubExecutionlog}"
			mkdir -p ${bsubExecutionlog}
			
			bsubcmd_FastqToBam="FastqToBam_jobid=\$(bsub -J FastqToBam_${sample_id}_${pid} -oo ${bsubExecutionlog}/FastqToBam_${sample_id}_${pid}.oo -eo ${bsubExecutionlog}/FastqToBam_${sample_id}_${pid}.eo < ${bsubExecutionStore}/fgbio_FastqToBam.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"
			bsubcmd_MergeSamFiles="MergeSamFiles_jobid=\$(bsub -J MergeSamFiles_${sample_id}_${pid} -w \"done(\${FastqToBam_jobid})\" -oo ${bsubExecutionlog}/MergeSamFiles_${sample_id}_${pid}.oo -eo ${bsubExecutionlog}/MergeSamFiles_${sample_id}_${pid}.eo < ${bsubExecutionStore}/picard_MergeSamFiles.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"
			bsubcmd_MergeBamAlignment="MergeBamAlignment_jobid=\$(bsub -J MergeBamAlignment_${sample_id}_${pid} -w \"done(\${MergeSamFiles_jobid})\" -oo ${bsubExecutionlog}/MergeBamAlignment_${sample_id}_${pid}.oo -eo ${bsubExecutionlog}/MergeBamAlignment_${sample_id}_${pid}.eo < ${bsubExecutionStore}/picard_MergeBamAlignment.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"
			bsubcmd_GroupReadsByUmi="GroupReadsByUmi_jobid=\$(bsub -J GroupReadsByUmi_${sample_id}_${pid} -w \"done(\${MergeBamAlignment_jobid})\" -oo ${bsubExecutionlog}/GroupReadsByUmi_${sample_id}_${pid}.oo -eo ${bsubExecutionlog}/GroupReadsByUmi_${sample_id}_${pid}.eo < ${bsubExecutionStore}/fgbio_GroupReadsByUmi.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"

			bsubcmd_CallMolecularConsensusReads="CallMolecularConsensusReads_jobid=\$(bsub -J CallMolecularConsensusReads_${sample_id}_${pid} -w \"done(\${GroupReadsByUmi_jobid})\" -oo ${bsubExecutionlog}/CallMolecularConsensusReads_${sample_id}_${pid}.oo -eo ${bsubExecutionlog}/CallMolecularConsensusReads_${sample_id}_${pid}.eo < ${bsubExecutionStore}/fgbio_CallMolecularConsensusReads.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}'); sleep 1s"

			bsubcmd_remapping_consensus="remapping_consensus_jobid=\$(bsub -J remapping_consensus_${sample_id}_${pid} -w \"done(\${CallMolecularConsensusReads_jobid})\" -oo ${bsubExecutionlog}/remapping_consensus_${sample_id}_${pid}.oo -eo ${bsubExecutionlog}/remapping_consensus_${sample_id}_${pid}.eo < ${bsubExecutionStore}/remapping_consensus.sh | awk '/is submitted/{print substr(\$2, 2, length(\$2)-2);}')"


### Writing serial bsub commands to bsubCall 
			echo "Create ${bsubExecutionStore}/bsubCall.sh"
			echo -e "${bsubcmd_FastqToBam}\n${bsubcmd_MergeSamFiles}\n${bsubcmd_MergeBamAlignment}\n${bsubcmd_GroupReadsByUmi}\n${bsubcmd_CallMolecularConsensusReads}\n${bsubcmd_remapping_consensus}" > ${bsubExecutionStore}/bsubCall.sh
			
			chmod 764 ${bsubExecutionStore}/*.sh
###
			echo "Execute bsub commands ${bsubExecutionStore}/bsubCall.sh"
			${bsubExecutionStore}/bsubCall.sh
	done

done
