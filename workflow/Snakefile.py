####################################################################################################
##                             Snakemake pipeline for Genome analysis                             ##
####################################################################################################

########################################
## To run the pipeline use this command#
########################################

'''
snakemake -s Snakefile.py --workflow-profile profiles/ga_pipeline/  -n
snakemake -s Snakefile.py --profile profiles/default -n
'''

########################################
## Python packages                    ##
########################################

import pandas as pd
import glob
import os


########################################
## Configuration                      ##
########################################

configfile: "../config/config.yaml" # where to find parameters

WORKING_DIR     = config["working_dir"]
OUTPUT_DIR      = config["output_dir"]
DATABASE_DIR    = config["database_dir"]
PROJECT_DIR     = config["project_dir"]
PROJECT_NAME    = config["project_name"]
ASSEMBLER       = config.get("assembler", "spades")

########################################
## Samples                            ##
########################################

## Raw read data
SAMPLES         = config["samples"]


## Additional genome data, for example downloaded from NCBI
GENOMES_DIR     = PROJECT_DIR + "ncbi_dataset/data"

fna_files = glob.glob(os.path.join(GENOMES_DIR, "*", "*.fna"))
genomes_map = {}
for f in fna_files:
    folder = os.path.basename(os.path.dirname(f))           # GCA_000236925.1
    basename = os.path.basename(f).replace("_genomic.fna", "")  # GCA_000236925.1_ASM23692v1
    genomes_map[folder] = basename

GENOMES         = sorted(genomes_map.keys())

ALL_GENOMES     = sorted(set(SAMPLES + GENOMES))

# Wähle erstes als Referenz
REF_SAMPLE = ALL_GENOMES[0]

print("SAMPLES:", SAMPLES) 
print("GENOMES:", GENOMES)
print("ALL_GENOMES:", ALL_GENOMES)

########################################
## Rules                              ##
########################################

# QC
include: "rules/fastp.smk"
include: "rules/fastqc.smk"
include: "rules/multiqc.smk"

## Assembly
if ASSEMBLER == "spades":
    include: "rules/spades.smk"
elif ASSEMBLER == "unicycler":
    include: "rules/unicycler.smk"
else:
    raise ValueError(f"Unknown assembler specified: {ASSEMBLER}")
#include: "rules/fix_contigs.smk"
include: "rules/quast.smk"

# Copy external genomes
include: "rules/copy_ncbi_data.smk"

## Annotation
include: "rules/prokka.smk"
include: "rules/copy_prokka_to_temp.smk"
include: "rules/emapper_kegganog.smk"
include: "rules/copy_emapper_to_temp.smk"

# SNP analysis 
include: "rules/copy_reference.smk"
include: "rules/refg_prokka.smk"
include: "rules/snippy.smk"

# Pangenome analysis
include: "rules/pirate.smk"
#include: "rules/anvio.smk"

# Typing
include: "rules/mlst.smk"
include: "rules/spaTyper.smk"
# coregenomeMLST

# AMR/virulence genes screening
include: "rules/abricate.smk"


########################################
## Desired outputs                    ##
########################################

MULTIQC                     = [OUTPUT_DIR + "qc/multiqc/multiqc_report.html"]
FASTP_OUTPUT                = expand(OUTPUT_DIR + "qc/fastp/{sample}_trimmed_R1.fastq.gz", sample=SAMPLES)
CONTIGS                     = expand(OUTPUT_DIR + "{sample}/assembly/contigs.fasta", sample=SAMPLES)
FIX_CONTIGS                 = expand(OUTPUT_DIR + "{sample}/assembly/contigs_fixed.fasta", sample=SAMPLES)
QUAST                       = expand(OUTPUT_DIR + "qc/quast/{sample}/report.html", sample=SAMPLES)
NCBI_GENOMES                = expand(WORKING_DIR + "genomes/{genome}.fasta", genome=GENOMES) 
NCBI_CONTIGS                = expand(OUTPUT_DIR + "{genome}/assembly/contigs_fixed.fasta", genome=GENOMES) 
PROKKA                      = expand(OUTPUT_DIR + "{all_genomes}/annotation/prokka/", all_genomes=ALL_GENOMES)
EMAPPER                     = expand(OUTPUT_DIR + "{all_genomes}/annotation/emapper/", all_genomes=ALL_GENOMES)
COPY_DEC_GFF                = expand(OUTPUT_DIR + "temp_genome_annotaions_gff/{all_genomes}.emapper.decorated.gff", all_genomes=ALL_GENOMES)
KEGGANOG                    = [OUTPUT_DIR + "kegganog/heatmap_figure.png"]
COPY_GFF                    = expand(OUTPUT_DIR + "temp_genome_gff/{all_genomes}.gff", all_genomes=ALL_GENOMES)
PIRATE                      = [OUTPUT_DIR + "pangenome/pirate/core_alignment.fasta"]
PAN_TREE                    = [OUTPUT_DIR + "pangenome/iqtree/iqtree.log"]
REFG_GBK                    = [WORKING_DIR + "reference/refg.gbk"]
SNIPPY                      = expand(OUTPUT_DIR + "variant_calling/snippy/{all_genomes}/snps.vcf", all_genomes=ALL_GENOMES)
COPY_VCF                    = expand(OUTPUT_DIR + "temp_genome_vcf/{all_genomes}.snps.vcf", all_genomes=ALL_GENOMES)
SNIPPY_CORE                 = [OUTPUT_DIR + "variant_calling/snippy-core/core.full.aln"]
CORE_TREE                   = [OUTPUT_DIR + "variant_calling/snippy-core/iqtree.log"]
VCF_HEATMAP                 = [OUTPUT_DIR + "variant_calling/vcf_viewer/heatmap_output.html"]
MLST                        = [OUTPUT_DIR + "typing/mlst/mlst.tsv"]
SPATYPER                    = expand(OUTPUT_DIR + "typing/spaTyper/{all_genomes}_spatype.txt", all_genomes=ALL_GENOMES) 
AMR_NCBI                    = expand(OUTPUT_DIR + "amr/{all_genomes}.ncbi.tsv", all_genomes=ALL_GENOMES) 
#AMR_TABLE                   = [OUTPUT_DIR + "amr/resistance_summary.tsv"]
#AMR_HEATMAP                = [OUTPUT_DIR + "amr/heatmap.png"]



########################################
## Pipeline                           ##
########################################

rule all:
    input:
        MULTIQC,
        FASTP_OUTPUT,
        CONTIGS,
        FIX_CONTIGS,
        QUAST, 
        NCBI_GENOMES, 
        NCBI_CONTIGS,
        PROKKA,
        COPY_GFF,
        PIRATE,
        PAN_TREE,
        MLST,
        SPATYPER,
        AMR_NCBI, 
        #AMR_TABLE,
        ### Optional steps depending on config
        *(EMAPPER if config["run"].get("emapper_kegganog") else []),
        *(COPY_DEC_GFF if config["run"].get("emapper_kegganog") else []),
        *(KEGGANOG if config["run"].get("emapper_kegganog") else []),
        *(REFG_GBK if config["run"].get("snippy") else []),
        *(SNIPPY if config["run"].get("snippy") else []),
        *(COPY_VCF if config["run"].get("snippy") else []), 
        *(SNIPPY_CORE if config["run"].get("snippy") else []),
        *(CORE_TREE if config["run"].get("snippy") else []),
        *(VCF_HEATMAP if config["run"].get("snippy_vcf_heatmap") else []),
    message:
        "The genome analysis pipeline finished successfully!"