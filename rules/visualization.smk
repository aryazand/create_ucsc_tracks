rule create_symlinks:
    input:
        bw = "results/tracks/{sample}_{species}_{direction}.bw",
        genome_data = "data/genome/{species}/{genome}.bed"
    output:
        bw = "results/UCSCGenomeBrowser/{species}/{genome}/bw/{sample}_{species}_{direction}.bw"
    log:
        "log/create_symlinks_{sample}_{species}_{direction}_{genome}.log"
    shell:
        """
        ln -sr {input.bw} {output.bw}
        """

# create bigbed for genome features
# TODO: recipe to download genome features from NCBI
rule create_bigbed:
    input:
        bed = "data/genome/{species}/{genome}.bed",
        chrom_sizes = "data/genome/{species}/{genome}.chrom.sizes"
    output:
        bigbed = "results/UCSCGenomeBrowser/{species}/{genome}/{genome}.bb"
    conda:
        "../envs/ucsc_tools.yml"
    log:
        "log/create_bigbed_{species}_{genome}.log"
    shell:
        """
        bedToBigBed {input.bed} {input.chrom_sizes} {output.bigbed}
        """

rule create_2bit:
    input:
        fasta = "data/genome/{species}/{genome}.fna"
    output:
        twobit = "results/UCSCGenomeBrowser/{species}/{genome}/sequence.2bit"
    conda:
        "../envs/ucsc_tools.yml"
    log:
        "log/create_2bit_{species}_{genome}.log"
    shell:
        """
        faToTwoBit {input.fasta} {output.twobit}
        """

# prepare a UCSC genome browser trackdb.txt file
# TODO: add track colors
rule create_trackdb:
    input:
        samples = expand("results/UCSCGenomeBrowser/{{species}}/{{genome}}/bw/{sample}_{{species}}_{direction}.bw", sample = sample_names, direction = ['rev', 'for']),
        bigbed = lambda wc: "results/UCSCGenomeBrowser/{species}/{genome}/{genome}.bb"
    output:
        trackdb_file = "results/UCSCGenomeBrowser/{species}/{genome}/trackDb.txt"
    log:
        "log/create_trackdb_{species}_{genome}.log"
    run:
        # create trackdb file
        with open(output.trackdb_file, 'w') as tf:
            
            track_db = [
                'track {}'.format(config["genomes"][wildcards.species]["genbank"]),
                'type bigGenePred',
                'group map',
                'priority 1',
                'bigDataUrl {}'.format(os.path.basename(input.bigbed)),
                'longLabel {}'.format(config["genomes"][wildcards.species]["longlabel"]), 
                'shortLabel {}'.format(config["genomes"][wildcards.species]["shortlabel"]),
                'visibility pack',
                ''
            ]

            for sample in sample_names:

                #hex_color = config["track_colors"][group] if group in config["track_colors"] else "#000000"
                #track_color = tuple(int(hex_color[i:i+2], 16) for i in (1, 3, 5)) # convert to RGB
                
                track = [
                    '##############################################',
                    '',
                    'track {}'.format(sample),
                    'container multiWig',
                    'type bigWig',
                    'aggregate transparentOverlay',
                    'showSubtrackColorOnUi on',
                    'shortLabel {}'.format(sample),
                    'longLabel {}'.format(sample),
                    '',
                    '\ttrack {}'.format(sample + "_for"),
                    '\tparent {}'.format(sample),
                    '\tshortLabel {}'.format(sample + "_forward"),
                    '\tlongLabel {}'.format(sample + "_forward"),
                    '\tbigDataUrl bw/{}.bw'.format(sample + "_" + wildcards.species + "_for"),
                    '\tparent {}'.format(sample),
                    '\ttype bigWig',
                    '\tcolor 113,35,124',
                    '', 
                    '\ttrack {}'.format(sample + "_rev"),
                    '\tparent {}'.format(sample),
                    '\tshortLabel {}'.format(sample + "_reverse"),
                    '\tlongLabel {}'.format(sample + "_reverse"),
                    '\tbigDataUrl bw/{}.bw'.format(sample + "_" + wildcards.species + "_rev"),
                    '\tparent {}'.format(sample),
                    '\ttype bigWig',
                    '\tcolor 113,35,124', 
                    ''
                ]
                
                track_db += track

            tf.write('\n'.join(track_db))

# create hub.txt file
rule create_hub:
    input:
        trackdb_file = lambda wc: "results/UCSCGenomeBrowser/{species}/" + config["genomes"][wc.species]["genbank"] + "/trackDb.txt"
    output:
        hub_file = "results/UCSCGenomeBrowser/{species}/hub.txt"
    log:
        "log/create_hub_{species}.log"
    params:
        shortlabel = lambda wc: config["genomes"][wc.species]["shortlabel"],
        longlabel = lambda wc: config["genomes"][wc.species]["longlabel"],
        email = config["ucsc"]["email"],
    shell:
        """
        echo "hub {wildcards.species}" > {output.hub_file}
        echo "shortLabel {params.shortlabel}" >> {output.hub_file}
        echo "longLabel {params.longlabel}" >> {output.hub_file}
        echo "genomesFile genomes.txt" >> {output.hub_file}
        echo "email {params.email}" >> {output.hub_file}
        """

# create genomes.txt file
rule create_genometxt: 
    input:
        trackdb_file = lambda wc: "results/UCSCGenomeBrowser/{species}/" + config["genomes"][wc.species]["genbank"] + "/trackDb.txt",
        twobit_file = lambda wc: "results/UCSCGenomeBrowser/{species}/" + config["genomes"][wc.species]["genbank"] + "/sequence.2bit"
    output:
        genomes_file = "results/UCSCGenomeBrowser/{species}/genomes.txt"
    log:
        "log/create_genometxt_{species}.log"
    params:
        genomes = lambda wc: config["genomes"][wc.species]["genbank"],
        shortlabel = lambda wc: config["genomes"][wc.species]["shortlabel"],
        defaultPos = lambda wc: config["genomes"][wc.species]["ucsc-defaultPos"]
    shell:
        """
        trackdb_path=$(realpath --relative-base=$(dirname {output.genomes_file}) {input.trackdb_file})
        twobit_path=$(realpath --relative-base=$(dirname {output.genomes_file}) {input.twobit_file})
        echo "genome {params.genomes}" > {output.genomes_file}
        echo "description {params.shortlabel}" >> {output.genomes_file}
        echo "trackDb $trackdb_path" >> {output.genomes_file}
        echo "twoBitPath $twobit_path" >> {output.genomes_file}
        echo "organism {wildcards.species}" >> {output.genomes_file}
        echo "defaultPos {params.defaultPos}" >> {output.genomes_file}
        """
        """