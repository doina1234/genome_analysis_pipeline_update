###########################################
### Genome Annotation with Eggnog-mapper ##
###########################################

rule clean_prokka_gff:
    input:
        gff                 = rules.prokka.output.gff
    output:
        clean_gff           = OUTPUT_DIR + "{all_genomes}/annotation/prokka/prokka_clean.gff"
    message:
        "Preprocessing GFF: remove header lines and invalid rows for emapper."
    shell:
        """
        awk '/^##FASTA/{{exit}} !/^##/' {input.gff} > {output.clean_gff}
        """

rule emapper:
    input:
        faa                 = rules.prokka.output.faa,
        gff                 = rules.clean_prokka_gff.output.clean_gff
    output:
        annotations         = OUTPUT_DIR + "{all_genomes}/annotation/emapper/{all_genomes}.emapper.annotations",
        decorated_gff       = OUTPUT_DIR + "{all_genomes}/annotation/emapper/{all_genomes}.emapper.decorated.gff",
        output_dir          = directory(OUTPUT_DIR + "{all_genomes}/annotation/emapper/")
    message:
        "Running Eggnog on prokka.faa and decorate prokka.gff with aditional annotaions"
    params:
        output_dir          = OUTPUT_DIR + "{all_genomes}/annotation/emapper/",
        emapper_data_dir    = DATABASE_DIR + "eggnog-mapper-data/",
        workflow_dir        = PROJECT_DIR + "workflow"
    conda: 
        "eggnog-mapper_env"
    shell:
        "mkdir -p {params.output_dir}; "
        "emapper.py "
        "-i {input.faa} "
        "--output_dir {params.output_dir} "
        "-o emapper "
        "--cpu {resources.cpus_per_task} "
        "--data_dir {params.emapper_data_dir} "
        "--decorate_gff {input.gff} "
        "--decorate_gff_ID_field locus_tag; "
        "rm -r {params.workflow_dir}/emappertmp_* || true; "
        "mv {params.output_dir}/emapper.emapper.annotations {output.annotations}; "
        "mv {params.output_dir}/emapper.emapper.decorated.gff {output.decorated_gff}; "

############################################
## Pathway compleatness visualization using KEGGaNOG #
############################################

rule create_annotation_list:
    input:
        emapper_annotations     = expand(rules.emapper.output.annotations, all_genomes=ALL_GENOMES)
    output:
        annotation_list         = OUTPUT_DIR + "kegganog/annotation.txt"
    params:
        output_dir              = OUTPUT_DIR + "kegganog/"
    message:
        "Creating annotation list for KEGGaNOG multi mode"
    shell:
        "mkdir -p {params.output_dir}; "
        "rm -f {output.annotation_list}; "
        "echo {input.emapper_annotations} | tr ' ' '\n' | sort > {output.annotation_list}"

rule kegganog:
    input:
        annotation_list         = rules.create_annotation_list.output.annotation_list
    output:
        kegganog_figure         = OUTPUT_DIR + "kegganog/heatmap_figure.png"
    params:
        output_dir              = OUTPUT_DIR + "kegganog/"
    conda:
        "kegganog_env"  
    message:
        "Running KEGGaNOG in multi mode on all annotation files"
    shell:
        "KEGGaNOG "
        "-M "
        "-dpi 600 "
        "-g "
        "-i {input.annotation_list} "
        "-o {params.output_dir}"





