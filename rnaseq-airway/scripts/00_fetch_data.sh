#!/usr/bin/env bash
# Étape 1 : téléchargement des FASTQ (SRA/ENA) + génome/annotation GENCODE.
# À lancer sur un noeud avec accès Internet (portable, ou noeud de login sur le cluster).
set -euo pipefail

FETCHNGS_VERSION="1.12.0"   # à vérifier sur nf-co.re/fetchngs
PROFILE="${1:-docker}"       # docker | apptainer

# --- FASTQ ---
nextflow run nf-core/fetchngs -r "$FETCHNGS_VERSION" \
  --input ids.csv \
  --nf_core_pipeline rnaseq \
  --outdir fetchngs_results \
  -profile "$PROFILE"

# --- Samplesheet avec noms d'échantillons lisibles (airway = non stranded) ---
bash scripts/make_samplesheet.sh

# --- Génome + annotation GENCODE v44 (GRCh38) ---
mkdir -p ref && cd ref
BASE=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44
wget -nc "$BASE/GRCh38.primary_assembly.genome.fa.gz"
wget -nc "$BASE/gencode.v44.primary_assembly.annotation.gtf.gz"
