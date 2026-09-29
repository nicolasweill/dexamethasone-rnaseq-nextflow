#!/usr/bin/env bash
# Version PORTABLE (sans GPU, ~16 Go RAM) : Salmon seul, pas de STAR.
# Sous Windows : lancer depuis WSL2 (Ubuntu) avec Docker Desktop (intégration WSL activée).
set -euo pipefail

VERSION="3.27.0"   # <-- fixer la dernière stable indiquée sur nf-co.re/rnaseq

# Vérification de l'installation (une seule fois) :
# nextflow run nf-core/rnaseq -r $VERSION -profile test,docker --outdir test_results

nextflow run nf-core/rnaseq -r "$VERSION" \
  --input samplesheet.csv \
  --fasta ref/GRCh38.primary_assembly.genome.fa.gz \
  --gtf ref/gencode.v44.primary_assembly.annotation.gtf.gz \
  --gencode \
  --aligner star_salmon \
  --pseudo_aligner salmon \
  --skip_alignment \
  --skip_qualimap --skip_rseqc --skip_dupradar \
  --outdir results_laptop \
  -c conf/laptop.config \
  -profile docker \
  -resume
