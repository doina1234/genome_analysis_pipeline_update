###########################################
### Creata Anvio pangenmoic ring plots   ##
###########################################

rule create_anvio_files:
    input:
        fasta_dir               = rules.copy_to_temp.output.output_fasta_dir
    ouput:
        pan-config_file         = OUTPUT_DIR + "anvio/pan-config.json",
        fasta_txt               = OUTPUT_DIR + "anvio/fasta.txt"
    message:
    params:
        output_dir              = OUTPUT_DIR + "anvio/",
    conda:
        "anvio-8"
    shell:
        "mkdir -p {params.output_dir}; "

        "anvi-run-workflow "
        "-w pangenomics "
        "--get-default-config "
        "{output.pan-config_file}; "



rule anvio:
    input:
        pan-config_file     = rules.rule create_anvio_files.output.pan-config_file
    output:
        genome_db           = OUTPUT_DIR + "anvio/03_PAN/{project_name}-GENOMES.db",
        pan_db              = OUTPUT_DIR + "anvio/03_PAN/{project_name}-PAN.db
    message:
        "Running Eggnog on prokka.faa and decorate prokka.gff with aditional annotaions"
    params:
        output_dir          = OUTPUT_DIR + "anvio/",
        emapper_data_dir    = DATABASE_DIR + "eggnog-mapper-data/",
        workflow_dir        = PROJECT_DIR + "workflow"
    conda: 
        "anvio-8"
    shell:
        "mkdir -p {params.output_dir}; "
        "anvi-setup-scg-taxonomy; "
        "anvi-setup-kegg-data; "
        "anvi-setup-ncbi-cogs; "
        "anvi-run-workflow "
        "-w pangenomics "
        "-c {input.pan-config_file} "
        "--additional-params "
        "--resources nodes={resources.cpus_per_task}; " 

        #"anvi-display-pan "
        #"-g 03_PAN/S_argenteus_adriana-GENOMES.db -p 03_PAN/S_argenteus_adriana-PAN.db
