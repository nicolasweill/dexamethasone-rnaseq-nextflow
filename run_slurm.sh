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

# rnaseq 3.27.0 exige Nextflow >= 25.10.4 (absent sur Narval) : on utilise la 26.04.4
# avec l'ancien analyseur de syntaxe, sinon elle ne lit pas le nextflow.config du pipeline.
module load StdEnv/2023 nextflow/26.04.4 apptainer
export NXF_SYNTAX_PARSER=v1
export NXF_OFFLINE=true   # noeuds de calcul sans Internet : pas de tentative de connexion

# Pipeline téléchargé (nf-core-rnaseq/3_27_0 = rnaseq 3.27.0), pas de -r pour un chemin local
PIPELINE="nf-core-rnaseq/3_27_0"

export NXF_OPTS='-Xms1g -Xmx4g'
export NXF_ANSI_LOG=false
export NXF_APPTAINER_CACHEDIR="$SCRATCH/apptainer_cache"
export NXF_SINGULARITY_CACHEDIR="$SCRATCH/apptainer_cache"

nextflow run "$PIPELINE" \
  --input samplesheet.csv \
  --fasta ref/GRCh38.primary_assembly.genome.fa.gz \
  --gtf ref/gencode.v44.primary_assembly.annotation.gtf.gz \
  --gencode \
  --aligner star_salmon \
  --skip_deseq2_qc \
  --outdir results_slurm \
  -c conf/slurm.config \
  -profile apptainer \
  -with-report results_slurm/nextflow_report.html \
  -with-trace results_slurm/nextflow_trace.txt \
  -resume
