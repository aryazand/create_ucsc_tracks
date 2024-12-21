import os
import pandas as pd
import pathlib
from snakemake.utils import Paramspace
samples = Paramspace(pd.read_csv("sample_metadata.csv"))
sample_names = set(samples.sample_name)

configfile: "config.yml"

rule all:
    input:
        genomes_file = expand("results/UCSCGenomeBrowser/{species}/genomes.txt", genome = 'cmv'),
        hub_file = expand("results/UCSCGenomeBrowser/{species}/hub.txt", genome = 'cmv'),
        trackdb_file = expand(os.path.join("results/UCSCGenomeBrowser/{species}/{genome}", , "trackDb.txt"), genome = 'cmv') 


include: "rules/visualization.smk"