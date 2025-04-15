# Genome analysis pipeline update
By Sara Schütz

This Snakemake pipeline is aimed to perform the assembly and annotation of paired-end sequencing reads, as well as to compare the genome content of the given DNA sequences. In addition, it performs a variant calling analysis in order to detect the SNPs across sequences, and it also determines the spa type. Given multiple paired-end sequencing reads (FASTQ files), it provides a table file showing the genome content comparison, and (multiple) tables showing the SNPs detected across strains. Outputs have the same format as given by software descirped below. The pipeline also provides the de novo assembly of the sequencing reads and their annotation.

## Overview
The Snakemake pipeline performs the following steps:

1. **Quality Control and Trimming**
   - `fastqc_raw`: Runs [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on raw sequencing reads to assess the quality of the reads by providing summary statistics and visualizations.
   - `fastp`: Uses [FastP](https://github.com/OpenGene/fastp)to remove low-quality bases and adapter sequences from raw reads to improve downstream analysis.
   - `fastqc_trimmed`: Runs FastQC again on the trimmed reads to verify the quality improvements made by Trimmomatic.
   - `multiqc`: Uses [MultiQC](https://multiqc.info/) to aggregate multiple FastQC reports into a single, comprehensive summary report.

2. **Genome Assembly**
   - `spades`: Runs [SPAdes](http://cab.spbu.ru/software/spades/) to assemble the processed reads into contiguous sequences (contigs).
   - `fix_contigs`: Fixes formatting issues in SPAdes contigs by trimming headers and ensuring compatibility with subsequent tools.
   - `quast`: Uses [QUAST](http://quast.sourceforge.net/quast) to assess the quality of the genome assembly by providing various metrics and visualizations.

3. **Genome Annotation**
   - `prokka`: Uses [Prokka](https://github.com/tseemann/prokka) to annotate the assembled contigs with gene functions, identifying coding sequences, rRNAs, tRNAs, and other genomic features.

4. **Spa Typing**
   - `spa_typing`: Uses [spaTyper](https://github.com/medvir/spaTyper) to determine spa types from the assembled contigs, which is useful for characterizing Staphylococcus aureus strains.

5. **Genome Content Analysis**
   - `copy_to_temp`: Copies GFF annotation files to a temporary directory for further analysis.
   - `pirate`: Runs [PIRATE](https://github.com/SionBayliss/PIRATE) for pangenome analysis, identifying core and accessory genes across multiple genomes.
   - `fasttree`: Uses [FastTree](http://www.microbesonline.org/fasttree/) to build a phylogenetic tree from PIRATE’s core alignment, providing insights into the evolutionary relationships among the genomes.

6. **Copy Reference**
   - `copy_reference_genome`: Copies reference genome files to a temporary directory for use in downstream analyses.
   - `copy_first_sample_gbk`: Copies the first sample’s Prokka GBK file to use as a reference in genome comparisons.

7. **SNP Detection**
   - `snippy`: Uses [Snippy](https://github.com/tseemann/snippy) to detect single nucleotide polymorphisms (SNPs) in each sample relative to the reference genome.
   - `snippy-core`: Combines the SNPs from multiple samples to create a core SNP alignment for phylogenetic analysis.

8. **Eggnog-mapper Orthology Prediction**
   - `eggnog-mapper`: Uses [eggNOG-mapper](http://eggnog-mapper.embl.de/) to perform fast functional annotation of the assembled contigs by mapping them to orthologous groups.
   - `KEGGaNOG`: Integrates [KEGG](https://www.genome.jp/kegg/) pathways with eggNOG annotations to provide insights into the biochemical pathways present in the genomes.


## Directory Structure
```
├── config
│   └── config.yaml
├── input
│   ├── adapters
│   ├── genomes
│   └── reference
├── output
└── workflow
```

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

