# Genome Analysis Pipeline Update
By Sara Schütz

This Snakemake-based pipeline automates the analysis of paired-end sequencing data for microbial genomes. It performs genome assembly, functional annotation, variant calling (SNP detection), pangenome analysis, and typing (e.g., spa typing, cgMLST), along with antimicrobial resistance (AMR) and virulence gene screening.

Given paired-end FASTQ files, the pipeline produces annotated assemblies, comparative genome content analysis, SNP reports across strains, and multiple visualizations including trees and heatmaps.


## Overview
The Snakemake pipeline performs the following steps:

1. **Quality Control and Trimming**
   - `fastp`: Performs quality filtering and adapter trimming on raw sequencing reads using [fastp](https://github.com/OpenGene/fastp).
	- `fastqc`: Runs [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on both raw and trimmed reads to assess read quality.
	- `multiqc`: Aggregates all FastQC reports into a single interactive summary using [MultiQC](https://multiqc.info/).

3. **Genome Assembly**
   - `spades`: Assembles trimmed reads into contigs using [SPAdes](http://cab.spbu.ru/software/spades/) (default assembler).
   - `unicycler`: Alternatively, runs [Unicycler](https://github.com/rrwick/Unicycler) if specified in config.yaml (assembler: unicycler).
   - `fix_contigs`: Cleans and standardizes SPAdes output headers to ensure compatibility with downstream tools.
   - `quast`: Evaluates assembly quality using [QUAST](http://quast.sourceforge.net/quast).

5. **Genome Annotation and Functional Prediction**
   - `prokka`:  Annotates assembled contigs with [Prokka](https://github.com/tseemann/prokka), identifying genes, rRNAs, tRNAs, and other features.
   - `eggnog-mapper`: Maps predicted proteins to orthologous groups and functional categories using [eggNOG-mapper](http://eggnog-mapper.embl.de/).
   - `KEGGaNOG`: Integrates KEGG pathway data with eggNOG annotations to provide insights into metabolic and functional pathways using [KEGGaNOG](https://github.com/iliapopov17/KEGGaNOG).

7. **Copy Files and Reference**
   - `copy_to_temp`: Copies prokka generated .faa and gff and fixed_contigs.fasta files to temporary directories for use in downstream analyses.
   - `copy_reference`: Uses a provided reference genome if available; otherwise, automatically selects the first samples .gbk file as the reference.
     
8. **Variant Calling and Visualization**
   - `snippy`: Detects single nucleotide polymorphisms (SNPs) relative to the reference genome using [Snippy](https://github.com/tseemann/snippy).
   - `snippy-core`: Combines the SNPs from multiple samples to create a core SNP alignment for phylogenetic analysis.
   - `tree`: Generates a tree out of the core SNP alignment using [IQ-TREE](http://www.iqtree.org).
   - `vcf_viewer`: Generates a heatmap to visualize variations across strains.

9. **Pangenome Analysis**
   - `pirate`: Runs [PIRATE](https://github.com/SionBayliss/PIRATE) for pangenome analysis, identifying core and accessory genes across multiple genomes.
   - `fasttree`: Uses [FastTree](http://www.microbesonline.org/fasttree/) to build a phylogenetic tree from PIRATE’s core alignment.
   - `anvio`: Runs [Anvi’o](https://anvio.org) pangenomic analysis [Anvi](https://anvio.org) and creates a ringplot. 
  
10. **AMR/virulence genes screening**
   - `abricate_heatmap`: Screens genomes for antimicrobial resistance and virulence genes using [ABRicate](https://github.com/tseemann/abricate) and visualizes results as a heatmap.
   
11. **Typing**
   - `spa_typing`: Uses [spaTyper](https://github.com/medvir/spaTyper) to determine spa types from the assembled contigs for characterizing Staphylococcus aureus strains.


## Directory Structure
```
├── config
│   └── config.yaml               # Config file for parameters & paths  
├── inputs
│   ├── adapters
│   │   └── adapters.fa           # Adapter sequences for trimming
│   ├── raw_reads                 # Input FASTQ files
│   │   ├── C22_R1.fastq.gz
│   │   ├── C22_R2.fastq.gz
│   │   ├── C24_R1.fastq.gz
│   │   └── C24_R2.fastq.gz
│   └── reference
│       └── refg.gbk              # Reference genomes (optional)      
├── output                        # All results
└── workflow                      # Snakemake rules, envs, scripts
    ├── envs
    ├── log
    ├── profiles
    │   ├── default
    │   └── ga_pipeline
    ├── rules
    └── scripts
```


## Installation

1. Clone this git repository
   ```bash
   git clone <repository-url>
   ```
2. If the conda environments are not installed on your computer, install using `conda env create -f <environment>.yml` command. The environment files are in `workflow/envs` directory.
   ```bash
   conda env create -f <environment>.yml
   ```
4. Eggnog Database: Follow Setup instructions eggnog-mapper documentation (https://github.com/eggnogdb/eggnog-mapper/wiki/eggNOG-mapper-v2.1.5-to-v2.1.12). I recommend to create a databases folder and add the eggnog-mapper-data folder in there. After a succesfull download, add the path to the databases in the config.yaml file, something like `path/databases/eggnog-mapper-data`.
5. Anvi: It is recommended to test the installation of all required tools, but especially verifying that Anvi’o is correctly installed and functional by running its built-in test suites:
   ```bash
   `anvi-self-test --suite mini`
   `anvi-self-test --suite pangenomics`
   ```


## Setup

1. Prepare the `config.yaml` file in the `config/` directory.
   ```yaml
   assembler: spades  # or unicycler
   database_dir: /path/to/databases/
   project_dir: /path/to/project/
   project_name: genome_analysis
   ```

2. Place input files in the appropriate subdirectories under `input/raw_reads`. The files should look like this:
   {sample_name}_R1_fastq.gz
   {sample_name}_R2_fastq.gz


## Usage

### Running on the SIT Cluster using Slurm

```bash
module load anaconda3
module load mamba
conda activate snakemake
cd workflow/
snakemake -s Snakefile.py \
    --workflow-profile ./profiles/ga_pipeline/
```

### Running Locally

```bash
conda activate snakemake
cd workflow/
snakemake -s Snakefile.py \
    --profile profiles/default
```

Note: Remove the `-n` flag after verifying the dry run.


### Outputs

## Output files

The pipeline generates the following outputs:

