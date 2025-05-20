###################################################
### Copy annotation files to a temporary folder  ##
###################################################

rule copy_emapper_to_temp:
    input:
        emapper                 = rules.emapper.output.annotations,
        emapper_gff             = rules.emapper.output.decorated_gff
    output:
        temp_emapper            = OUTPUT_DIR + "temp_genome_annotaions/{all_genomes}.emapper.annotations",
        temp_emapper_gff        = OUTPUT_DIR + "temp_genome_annotaions_gff/{all_genomes}.emapper.decorated.gff"
    params:
        output_dir_emapper      = OUTPUT_DIR + "temp_genome_annotaions/",
        output_dir_emapper_gff  = OUTPUT_DIR + "temp_genome_annotaions_gff/"
    message:
        "Copying annotaion files to temp folder"
    shell:
        "mkdir -p {params.output_dir_emapper}; "
        "mkdir -p {params.output_dir_emapper_gff}; "
        "cp {input.emapper} {output.temp_emapper}; "
        "cp {input.emapper_gff} {output.temp_emapper_gff}; "



