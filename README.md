# Genome Analysis Pipeline Update

This Snakemake-based pipeline automates the analysis of paired-end sequencing data for microbial genomes. It performs genome assembly, functional annotation, variant calling (SNP detection), pangenome analysis, and typing (e.g., spa typing, MLST, cgMLST), along with antimicrobial resistance (AMR) and virulence gene screening.

## Overview
The Snakemake pipeline performs the following steps (by default/optional):

**- Quality Control and Trimming (default)**
   	- `fastp`: Performs quality filtering and adapter trimming on raw sequencing reads using [fastp](https://github.com/OpenGene/fastp).
	- `fastqc`: Runs [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on both raw and trimmed reads to assess read quality.
	- `multiqc`: Aggregates all FastQC reports into a single interactive summary using [MultiQC](https://multiqc.info/).

**- Genome Assembly (default)**
   	- `spades`: Assembles trimmed reads into contigs using [SPAdes](http://cab.spbu.ru/software/spades/) (default).
   	- `unicycler`: Alternatively, runs [Unicycler](https://github.com/rrwick/Unicycler) if specified in config.yaml (assembler: unicycler).
   	- `quast`: Evaluates assembly quality using [QUAST](http://quast.sourceforge.net/quast).

**- Genome Annotation and Functional Prediction**
   	- `prokka`:  Annotates assembled contigs with [Prokka](https://github.com/tseemann/prokka), identifying genes, rRNAs, tRNAs, and other features (default).
   	- `bakta`: Annotates assembled contigs with [Bakta](https://github.com/oschwengers/bakta) if specified in config.yaml (annotator: bakta).
   	- `emapper_kegganog`: Maps predicted proteins to orthologous groups and functional categories using [eggNOG-mapper](http://eggnog-mapper.embl.de/) and integrates KEGG pathway data with eggNOG annotations to provide insights into metabolic and functional pathways using [KEGGaNOG](https://github.com/iliapopov17/KEGGaNOG) (optional).
   	  
**- Pangenome Analysis**
   	- `pirate`: Runs [PIRATE](https://github.com/SionBayliss/PIRATE) for pangenome analysis, identifying core and accessory genes across multiple genomes (default).
	- `iqtree`: Generates a tree out of the core SNP alignment using [IQ-TREE](http://www.iqtree.org) (default)
	- `snp-dists`: Calculates pairwise nucleotide differences from the core gene-by-gene alignment using [snp-dists](https://github.com/tseemann/snp-dists) (default).
	- `anvio`: Runs [Anvi’o](https://anvio.org) pangenomic analysis and creates databases for a ringplot (optional) (-->see some solutions). 
  
**- Variant Calling and Visualization**
   	- `snippy`: Detects single nucleotide polymorphisms (SNPs) relative to the reference genome using [Snippy](https://github.com/tseemann/snippy) (default).
   	- `snippy-core`: Combines the SNPs from multiple samples to create a core SNP alignment for phylogenetic analysis, generates a tree out of the core SNP alignment using [IQ-TREE](http://www.iqtree.org) (default).
    	- `snp-dists`: Calculates pairwise SNP differences from the core SNP alignment using [snp-dists](https://github.com/tseemann/snp-dists) (default).
   	- `vcf_viewer`: Generates a heatmap to visualize variations across strains (optional) --> difficult to execute if there are too many snps, but you could filter them first?.
  
**- AMR/virulence genes screening (optional)**
	- `abricate`: Screens genomes for antimicrobial resistance and virulence genes using [ABRicate](https://github.com/tseemann/abricate) blasting against the virulence factor database [VFDB](http://www.mgc.ac.cn/VFs/), [NCBI AMRFinderPlus](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA313047), [CARD](https://card.mcmaster.ca), [Resfinder](https://cge.cbs.dtu.dk/services/ResFinder) and [PlasmidFinder](https://cge.cbs.dtu.dk/services/PlasmidFinder). Results from each database are summarized individually to be visualized as a heatmap.
   
**- Typing (optional)**
	- `spa_typing`: Uses [spaTyper](https://github.com/medvir/spaTyper) to determine spa types from the assembled contigs for characterizing Staphylococcus aureus strains.
 	- `mlst`: Uses [mlst]([https://github.com/tseemann/mlst)]) to determine the MLST types from the assembled contigs.
  	- `chewbacca`: Uses [chewBBACA](https://github.com/B-UMMI/chewBBACA) to determine the cgMLST of the assembled contigs--> see soem solutions (optional).


## Directory Structure
```
├── config
│   └── config.yaml               # Config file for parameters & paths  
├── inputs
│   ├── adapters
│   │   └── adapters.fa           # Adapter sequences for trimming
│   ├── genomes			  # External genomes (See some solutions section)    
│   ├── raw_reads                 # Input FASTQ files
│   │   ├── C22_R1.fastq.gz
│   │   ├── C22_R2.fastq.gz
│   │   ├── C24_R1.fastq.gz
│   │   └── C24_R2.fastq.gz
│   └── reference
│       └── refg.fasta            # Reference genome (optional)   
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
   git clone <https://github.com/doina1234/genome_analysis_pipeline_update/tree/main>
   ```
2. If the conda environments are not installed on your computer, install using `conda env create -f <environment>.yml` command. The environment files are in `workflow/envs` directory.
   ```bash
   conda env create -f workflow/envs/<environment>.yml
   ```
4. Eggnog Database: Follow Setup instructions eggnog-mapper documentation (https://github.com/eggnogdb/eggnog-mapper/wiki/eggNOG-mapper-v2.1.5-to-v2.1.12). I recommend to create a databases folder and add the eggnog-mapper-data folder in there. After a succesfull download, add the path to the databases in the `config.yaml file`, something like `path/databases/eggnog-mapper-data`.
   
5. Anvi’o: It is recommended to test the installation of all required tools, but especially verifying that Anvi’o is correctly installed and functional by running its built-in test suites:
   ```bash
   conda activate anvio-8
   anvi-self-test --suite mini
   anvi-self-test --suite pangenomics
   conda deactivate
   ```


## Setup

1. Prepare the `config.yaml` file in the `config/` directory.
   ```yaml
   samples:
   - C22
   - C24

   assembler: spades  # or unicycler
   database_dir: /path/to/databases/
   project_dir: /path/to/project/
   project_name: genome_analysis
   ```

2. Place input files in the appropriate subdirectories under `input/raw_reads`. The files should look like this:
   `{sample_name}_R1_fastq.gz`
   `{sample_name}_R2_fastq.gz`

3. Set optional tool to true if you want to run it...

## Usage

### Running on the SIT Cluster using Slurm

```bash
module load anaconda3
module load mamba
conda activate snakemake
cd workflow/
snakemake -s Snakefile.py --workflow-profile profiles/ga_pipeline/
```

### Running Locally

```bash
conda activate snakemake
cd workflow/
snakemake -s Snakefile.py --profile profiles/default
```

Note: Remove the `-n` flag after verifying the dry run.


### Outputs

The pipeline generates the following outputs:
(tree) saschuet@u20-login-1:/shares/kouyos.virology.uzh/sara/projects/genome_analysis_pipeline_update_git_new/output$ tree -L 2
```
.
├── 01_qc
│   ├── fastp
│   ├── fastqc
│   ├── multiqc
│   ├── quast
│   └── summary_qc.tsv
├── 02_kegganog
├── 03_pangenome
│   └──  pirate
├── 04_variant_calling
│   ├── snippy
│   └── snippy-core
├── 05_gwas
├── 06_typing
│   ├── chewbacca
│   ├── mlst
│   └── spaTyper
├── 07_amr
├── 08_temp
│   ├── temp_faa
│   ├── temp_fasta
│   ├── temp_gff
│   ├── temp_vcf
│   └── temp_vcf_gz
├── C22
│   ├── annotation
│   │   ├── bakta
│   │   ├── emapper
│   │   └── prokka
│   └── assembly
│       ├── contigs_fixed.fasta
│       ├── spades
│       └── unicycler
├── C24
├── C28
└── C32
```

## Some solutions

### Add additional genomes to the analysis (for example NCBI downloads)
- Download genome into project folder.
- Unzip folder:
```
unzip ncbi-dataset.zip
```
### Display anvios ringplot on your local computer
- Install anvio environement on your local computer.
- Download ../output/03_pangenome/anvio/anvio_Pangenome-PAN.db and ../output/03_pangenome/anvio/anvio_storage-GENOMES.db files.
- Display data:
```
conda activate anvio-8
anvi-display-pan -g anvio_storage-GENOMES.db -p anvio_Pangenome-PAN.db
```
-->make your ringplot pretty on the anvio server...

### Download cgmlst alleles
- Download alleles as fasta from into `path/databases/{data_source_speciesname}/alleles/`
	- cgmlst.org
	- chewbbaca.online
