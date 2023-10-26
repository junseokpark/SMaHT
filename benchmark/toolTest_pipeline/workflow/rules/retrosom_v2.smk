##

rule RetroSom_v2:
    input:
        bam=""
    output:
        bam=""
    singularity:
        "docker://"
    log:
        file="logs/xTEA_mosaic/{sample}.log"
    script:
        "some script for singularity"