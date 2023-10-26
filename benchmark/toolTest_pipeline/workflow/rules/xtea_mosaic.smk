rule create_input_list:
    input:
        samples = ""  # input config file
    output:
        sample_id.txt
        illumina_bam_list.txt
    log:
    script:
        """
        #1 Create sample_id.txt file
        #2 Create bam_list.txt file

        """

PROJECT_PATH=
REF_PATH=
WORK_PATH=


rule xTEA_mosaic:
    input:
        bam=""
        rep_lib_annotation=""
        ref=""
        

    output:
        bam=""
    singularity:
        "docker://"
    log:
        file="logs/xTea_mosaic/{sample}.log"
    script:
        """
        python /home/xTea_mosaic/gnrt_pipeline_local_v38.py \
         -M -U -i sample_id.txt \
         -b illumina_bam_list.txt \
         -x null \
         -p ./path_work_folder/ \
         -o submit_jobs.sh \
         -l /home/rep_lib_annotation/ \
         -r /home/reference/genome.fa \
         -g ref/pangenomics/chm13.draft_v2.0.gene_annotation.gff3 \
         --xtea /home/ec2-user/xTea/xtea/ \
         -f 5907 \
         -y 3 \
         --slurm -t 10-12:00 -q short -n 8 -m 96 \
         --nclip 2 --cr 0 --nd 1 --nfclip 1 --nfdisc 1 \
         --blacklist /home/germline_insertions.bed 
        """