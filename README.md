# genome_analysis_pipeline_update
by Judith Bergadà Pijuan

This Snakemake pipeline is aimed to perform the assembly and annotation of paired-end sequencing reads, as well as to compare the genome content of the given DNA sequences. In addition, it performs a variant calling analysis in order to detect the SNPs across sequences, and it also determines the spa type. Given multiple paired-end sequencing reads (FASTQ files), it provides a table file showing the genome content comparison, and (multiple) tables showing the SNPs detected across strains. Outputs have the same format as given by software Roary and Snippy. The pipeline also provides the de novo assembly of the sequencing reads and their annotation.

## Overview

The Snakemake pipeline performs the following steps:

1. Quality Control and Trimming
  - fastqc_raw: Runs FastQC on raw sequencing reads to assess quality.
  - trimmomatic: Uses Trimmomatic to trim low-quality bases and adapters from raw reads.
  - fastqc_trimmed: Runs FastQC on trimmed reads to verify improvements.
  - multiqc: Uses MultiQC to aggregate FastQC reports into a single summary.

2. Genome Assembly
  - spades: Runs SPAdes to assemble reads into contigs.
  - fix_contigs: Fixes formatting issues in SPAdes contigs (trims headers).
  - quast: Uses QUAST to assess assembly quality.

3. Genome Annotation
- prokka: Uses Prokka to annotate assembled contigs with gene functions.

5. Spa Typing
  - spa_typing: Uses spaTyper to determine spa types from assembled contigs.

5. Genome Content Analysis
  - copy_to_temp: Copies GFF annotation files to a temporary directory.
  - pirate: Runs PIRATE for pangenome pangenome analysis.
  - fasttree: Uses FastTree to build a phylogenetic tree from PIRATE’s core alignment.

6. Copy Refernce
  - copy_reference_genome: Copies reference genome files to a temporary directory.
  - copy_first_sample_gbk: Copies the first sample’s Prokka GBK file as a reference.

7. SNP Detection
   - snippy: Uses Snippy to detect SNPs in each sample relative to the reference genome.
   - snippy-core
    
9. Eggnog-mapper Orthology Prediction
  - eggnog-mapper
  - KEGGaNOG

## Dirctory

├── config
│   └── config.yaml
├── input
│   ├── adapters
│   ├── genomes
│   └── reference
├── output
└── workflow

## Installation

1. Clone this git repository
2. If the conda environments are not installed on your computer, install using `conda env create -f <environment>.yml` command. The environment files are in `workflow/envs` directory.

## Setup


## Usage

### Running on the SIT Cluster using Slurm

```bash
tmux
conda activate snakemake
cd workflow/
snakemake -s ga_pipeline.py \
    --configfile ../config/config.yaml \
    genomes_dir=../inputs/genomes/ \
    output_dir=../results\
    --workflow-profile ./profiles/ga_pipeline/
```

### Running Locally

```bash
conda activate snakemake
cd workflow/
snakemake -s ga_pipeline.py \
    --configfile ../config/config.yaml \
    genomes_dir=../inputs/genomes/ \
    result_dir=results_new \
    --profile profiles/default
```

Note: Remove the `-n` flag after verifying the dry run.


## Pipeline Output

The pipeline generates the following outputs:

