#!/usr/bin/env bash
# Étape 1 : téléchargement des FASTQ (ENA) + génome/annotation GENCODE + samplesheet.
# À lancer sur un noeud avec Internet (noeud de login sur Narval), depuis rnaseq-airway/.
set -euo pipefail

mkdir -p fastq ref

# --- FASTQ : URLs obtenues via l'API ENA, à partir de ids.csv ---
while read -r run; do
  [[ -z "$run" ]] && continue
  urls=$(curl -s "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${run}&result=read_run&fields=fastq_ftp&format=tsv" \
         | tail -n +2 | cut -f2 | tr ';' '\n')
  [[ -n "$urls" ]] || { echo "Aucune URL ENA pour $run" >&2; exit 1; }
  for u in $urls; do
    wget -nc -P fastq "ftp://${u}" || wget -nc -P fastq "https://${u}"
  done
done < ids.csv

# --- Génome + annotation GENCODE v44 (GRCh38) ---
BASE=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44
wget -nc -P ref "$BASE/GRCh38.primary_assembly.genome.fa.gz"
wget -nc -P ref "$BASE/gencode.v44.primary_assembly.annotation.gtf.gz"

# --- Samplesheet (noms lisibles, non stranded) ---
bash scripts/make_samplesheet.sh
