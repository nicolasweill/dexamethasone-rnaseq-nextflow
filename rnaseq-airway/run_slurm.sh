#!/bin/bash
#SBATCH --job-name=nf-airway
#SBATCH --account=def-XXXXX          # <-- ton compte
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --output=nf-airway-%j.out
# Job "chef d'orchestre" : Nextflow soumet lui-même les tâches SLURM.
# Soumettre avec : sbatch run_slurm.sh
#
# NB Alliance (Narval/Béluga) : les noeuds de calcul n'ont pas d'Internet.
# Télécharger d'abord sur le noeud de login : FASTQ + génome (scripts/00_fetch_data.sh apptainer)
# et les images : nf-core download rnaseq -r $VERSION --container-system singularity --outdir nf-core-rnaseq
# puis lancer avec le chemin local du pipeline (voir PIPELINE ci-dessous).
set -euo pipefail

module load StdEnv/2023 java/17 nextflow apptainer

VERSION="3.14.0"   # <-- fixer la dernière stable
PIPELINE="nf-core/rnaseq"                       # en ligne (si Internet disponible)
# PIPELINE="nf-core-rnaseq/3_14_0"              # hors ligne, après nf-core download

export NXF_OPTS='-Xms1g -Xmx4g'
export NXF_ANSI_LOG=false
export NXF_APPTAINER_CACHEDIR="$SCRATCH/apptainer_cache"

nextflow run "$PIPELINE" -r "$VERSION" \
  --input samplesheet.csv \
  --fasta ref/GRCh38.primary_assembly.genome.fa.gz \
  --gtf ref/gencode.v44.primary_assembly.annotation.gtf.gz \
  --gencode \
  --aligner star_salmon \
  --outdir results_slurm \
  -c conf/slurm.config \
  -profile apptainer \
  -resume
