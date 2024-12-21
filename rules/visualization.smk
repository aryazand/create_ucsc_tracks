rule create_symlinks:
    input:
        bw = "results/tracks/{sample}_{species}_{direction}.bw"
    output:
        bw = "results/UCSCGenomeBrowser/{species}/" + config["{species}"]["genbank"] + "/{sample}_{species}_{direction}.bw"
    shell:
        """
        ln -sr {input.bw} {output.bw}
        """

# prepare a UCSC genome browser track hub
rule ucsc_hub:
    input:
        expand("results/UCSCGenomeBrowser/{{species}}/" + config["{species}"]["genbank"] +"/{sample}_{{species}}_{direction}.bw", sample = sample_names, direction = ['rev', 'for'])
    output:
        genomes_file = "results/UCSCGenomeBrowser/{species}/genomes.txt",
        hub_file = "results/UCSCGenomeBrowser/{species}/hub.txt",
        trackdb_file = "results/UCSCGenomeBrowser/{species}/" + genome = config["{species}"]["genbank"] + "/trackDb.txt"
    log:
        "logs/ucsc_hub_{genome}.log"
    run:
        # #create genomes.txt
        with open(output.genomes_file, 'w') as gf:
            genomes_text = f'genome {config[wildcards.species]['genbank']}\ntrackDb  {config[wildcards.species]['genbank']}/trackDb.txt\n'
            gf.write(genomes_text)

        # #create hub file
        with open(output.hub_file, 'w') as hf:
            hub_text = [f'hub {config["project_name"]}',
                        f'shortLabel {config["project_name"]}',
                        f'longLabel {config["project_name"]}',
                        'genomesFile genomes.txt',
                        f'email {config["email"]}\n',]
            hf.write('\n'.join(hub_text))

        # create trackdb file
        # with open(output.trackdb_file, 'w') as tf:
            
        #     track_db = ['track {}'.format(config["project_name"]),
        #                 'type bigWig', 'compositeTrack on', 'autoScale on', 'maxHeightPixels 32:32:8',
        #                 'shortLabel {}'.format(config["project_name"][:8]),
        #                 'longLabel {}'.format(config["project_name"]),
        #                 'visibility full',
        #                 '', '']

        #     for sample in sample_names:

        #         #hex_color = config["track_colors"][group] if group in config["track_colors"] else "#000000"
        #         #track_color = tuple(int(hex_color[i:i+2], 16) for i in (1, 3, 5)) # convert to RGB
                
        #         track = ['track {}'.format(sample),
        #                  'container multiWig',
        #                  'aggregate transparentOverlay',
        #                  'showSubtrackColorOnUi on',
        #                  'shortLabel {}'.format(sample),
        #                  'longLabel {}'.format(sample),
        #                  '',
        #                  '\ttrack {}'.format(sample + "_for"),
        #                  '\tparent {}'.format(sample),
        #                  '\tshortLabel {}'.format(sample + "_forward"),
        #                  '\tlongLabel {}'.format(sample + "_forward"),
        #                  '\tbigDataUrl {}.bw'.format(sample + "_" + wildcards.species + "_for"),
        #                  '\tparent {}'.format(sample),
        #                  '\ttype bigWig',
        #                  '\tcolor 113,35,124',
        #                  '', 
        #                  '\ttrack {}'.format(sample + "_rev"),
        #                  '\tparent {}'.format(sample),
        #                  '\tshortLabel {}'.format(sample + "_reverse"),
        #                  '\tlongLabel {}'.format(sample + "_reverse"),
        #                  '\tbigDataUrl {}.bw'.format(sample + "_" + wildcards.species + "_rev"),
        #                  '\tparent {}'.format(sample),
        #                  '\ttype bigWig',
        #                  '\tcolor 113,35,124', 
        #                  '']
                
        #         track_db += track

        #     tf.write('\n'.join(track_db))