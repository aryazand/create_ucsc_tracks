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
        genomes_file = expand("results/UCSCGenomeBrowser/{species}/genomes.txt", species = config["genomes"].keys()),
        hub_file = expand("results/UCSCGenomeBrowser/{species}/hub.txt", species = config["genomes"].keys()),
        trackdb_file = expand("results/UCSCGenomeBrowser/{species}/{genome}/trackDb.txt", species = config["genomes"].keys(), genome = config["genomes"]['cmv']['genbank']) 

include: "rules/visualization.smk"