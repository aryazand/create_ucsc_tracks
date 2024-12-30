import os
import pandas as pd
import pathlib
from snakemake.utils import Paramspace
samples = Paramspace(pd.read_csv("sample_metadata.csv"))
sample_names = set(samples.sample_name)

configfile: "config.yml"

# TODO: define expand parameters from config file
rule all:
    input:
        genomes_file = expand("results/UCSCGenomeBrowser/{species}/genomes.txt", species = 'cmv'),
        hub_file = expand("results/UCSCGenomeBrowser/{species}/hub.txt", species = 'cmv'),
        trackdb_file = expand("results/UCSCGenomeBrowser/{species}/{genome}/trackDb.txt", species = 'cmv', genome = config["genomes"]['cmv']['genbank']) 


include: "rules/visualization.smk"