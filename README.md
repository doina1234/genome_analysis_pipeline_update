# Genome Analysis Pipeline Update
By Sara Schütz

This Snakemake-based pipeline automates the analysis of paired-end sequencing data for microbial genomes. It performs genome assembly, functional annotation, variant calling (SNP detection), pangenome analysis, and typing (e.g., spa typing, cgMLST), along with antimicrobial resistance (AMR) and virulence gene screening.

Given paired-end FASTQ files, the pipeline produces annotated assemblies, comparative genome content analysis, SNP reports across strains, and multiple visualizations including trees and heatmaps.


## Overview
The Snakemake pipeline performs the following steps:

1. **Quality Control and Trimming**
   - `fastp`: Uses [fastp](https://github.com/OpenGene/fastp) to remove low-quality bases and adapter sequences from raw reads to improve downstream analysis.
   - `fastqc`: Runs [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on raw sequencing and trimmed reads.
   - `multiqc`: Uses [MultiQC](https://multiqc.info/) to aggregate multiple FastQC reports into summary report.

2. **Genome Assembly**
   - `spades`: Runs [SPAdes](http://cab.spbu.ru/software/spades/) to assemble the processed reads into contiguous sequences (contigs) (default).
   - `unicycler`: If you sspecifiy in the config.yaml file `assembler: unicycler`, you can run [Unicycler](https://github.com/rrwick/Unicycler) as alternative.
   - `fix_contigs`: Fixes formatting issues in SPAdes contigs by trimming headers and ensuring compatibility with subsequent tools.
   - `quast`: Uses [QUAST](http://quast.sourceforge.net/quast) to assess the quality of the genome assembly.

3. **Genome Annotation and Orthology Prediction**
   - `prokka`: Uses [Prokka](https://github.com/tseemann/prokka) to annotate the assembled contigs with gene functions, identifying coding sequences, rRNAs, tRNAs, and other genomic features.
   - `eggnog-mapper`: Uses [eggNOG-mapper](http://eggnog-mapper.embl.de/) to perform fast functional annotation of the assembled contigs by mapping them to orthologous groups.
   - `KEGGaNOG`: Integrates [KEGG](https://www.genome.jp/kegg/) pathways with eggNOG annotations to provide insights into the biochemical pathways present in the genomes.

4. **Copy Files and Reference**
   - `copy_to_temp`: Copies prokka generated .faa and gff and fived_contigs.fasta files to temporary directories for use in downstream analyses.
   - `copy_reference`: Checks if reference was provided, otherwise opies the first sample’s prokka .gbk file to use as a reference.
     
5. **SNP Detection**
   - `snippy`: Uses [Snippy](https://github.com/tseemann/snippy) to detect single nucleotide polymorphisms (SNPs) in each sample relative to the reference genome.
   - `snippy-core`: Combines the SNPs from multiple samples to create a core SNP alignment for phylogenetic analysis.
   - `tree`: generates a tree out of the core SNP alignment.
   - `vcf_viewer`: Generates a heatmap of SNP between the samples.

6. **Pangenome Analysis**
   - `pirate`: Runs [PIRATE](https://github.com/SionBayliss/PIRATE) for pangenome analysis, identifying core and accessory genes across multiple genomes.
   - `fasttree`: Uses [FastTree](http://www.microbesonline.org/fasttree/) to build a phylogenetic tree from PIRATE’s core alignment, providing insights into the evolutionary relationships among the genomes.
   - `anvio`: Perfome a anvio's pangenomic analysis [Anvi](https://anvio.org) and create a ringplot.
  
7. **AMR/virulence genes screening**
   - `abricate_heatmap`: 
   
8. **Typing**
   - `spa_typing`: Uses [spaTyper](https://github.com/medvir/spaTyper) to determine spa types from the assembled contigs, which is useful for characterizing Staphylococcus aureus strains.


## Directory Structure
```
├── config                  
│   └── config.yaml         # Config file for parameters & paths         
├── input
│   ├── adapters            # Adapter sequences for trimming
│   ├── genomes             # Input FASTQ files
│   └── reference           # Reference genomes (optional)
├── output                  # All results
└── workflow                # Snakemake rules, envs, scripts
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
5. Anvi: I recommend testing the installation of all the programms, but espessialy the anvio installation:
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

2. Place input files in the appropriate subdirectories under `input/genomes`. The files should look like this:
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

