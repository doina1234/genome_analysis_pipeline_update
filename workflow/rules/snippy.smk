###################################################
## Variant calling and visualization             ##
###################################################

rule snippy:
    input:
        fixed_contigs       = OUTPUT_DIR + "{all_genomes}/assembly/contigs_fixed.fasta",
        refg                = rules.refg_prokka.output.refg_gbk
    output:
        snippy_output       = OUTPUT_DIR + "variant_calling/snippy/{all_genomes}/snps.vcf"
    params:
        output_dir          = OUTPUT_DIR + "variant_calling/snippy/{all_genomes}/"
    conda: "snippy_env"
    shell:
        "mkdir -p {params.output_dir}; "
        "snippy "
        "--report "
        "--cpus {resources.cpus_per_task} "
        "--outdir {params.output_dir} "
        "--ref {input.refg} "
        "--ctgs {input.fixed_contigs} "
        "--force; "

rule copy_snippy_to_temp:
    input:
        vcf                     = rules.snippy.output.snippy_output
    output:
        temp_vcf                = OUTPUT_DIR + "temp_genome_vcf/{all_genomes}.snps.vcf"
    params:
        output_dir_vcf          = OUTPUT_DIR + "temp_genome_vcf/"
    message:
        "Copying snippy vcf files to temp folder"
    shell:
        "mkdir -p {params.output_dir_vcf}; "
        "echo {input.vcf}; "
        "cp {input.vcf} {output.temp_vcf}; "


rule snippy_core:
    input:
        refg                       = rules.refg_prokka.output.refg_gbk
    output:
        aln                        = OUTPUT_DIR + "variant_calling/snippy-core/core.aln",
        vcf                        = OUTPUT_DIR + "variant_calling/snippy-core/core.vcf",
        full_aln                   = OUTPUT_DIR + "variant_calling/snippy-core/core.full.aln"
    params:
        prefix = OUTPUT_DIR + "variant_calling/snippy-core/core",
        snippy_dirs = lambda wildcards: " ".join([
            OUTPUT_DIR + f"variant_calling/snippy/{sample}"
            for sample in ALL_GENOMES if sample != REF_SAMPLE
        ]),
        output_dir = OUTPUT_DIR + "variant_calling/snippy-core/"
    message:
        "Aligning core and whole genomes into a multi fasta file"
    conda: 
        "snippy_env"
    shell:
        "echo 'Reference genome: {input.refg}'; "
        "echo 'Including snippy directories: {params.snippy_dirs}'; "
        "mkdir -p {params.output_dir}; "
        "snippy-core "
        "--ref {input.refg} "
        "--prefix {params.prefix} "
        "{params.snippy_dirs}; "

        
rule tree:
    input:
        aln                     = rules.snippy_core.output.full_aln
    output:
        iqtree_log              = OUTPUT_DIR + "variant_calling/snippy-core/iqtree.log"
    message:
        "Builing phylogeny tree of whole genomes using IQ-Tree"
    conda: 
        "iqtree_env"
    shell:
        "iqtree "
        "-s {input.aln} "
        "-bb 1000 "
        "> {output}; "

rule vcf_viewer:
    input:
        vcf                     = rules.snippy_core.output.vcf
    output:
        heatmap_figure          = OUTPUT_DIR + "variant_calling/vcf_viewer/heatmap_output.html"
    params:
        output_dir              = OUTPUT_DIR + "variant_calling/vcf_viewer/"
    message:
        "Generating SNP heatmap"
    shell:
        "mkdir -p {params.output_dir}; "
        "Rscript scripts/vcf2heatmap.R {input.vcf} > {output.heatmap_figure}"


    