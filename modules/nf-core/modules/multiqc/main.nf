process MULTIQC {
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::multiqc=1.13a' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.13a--pyhdfd78af_1' :
        'quay.io/biocontainers/multiqc:1.13a--pyhdfd78af_1' }"

    input:
    path  multiqc_files, stageAs: "?/*"
    path(multiqc_config)
    path(multiqc_logo)

    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots
    path "versions.yml"        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def config = multiqc_config ? "--config $multiqc_config" : ''
    """
    multiqc \\
        --force \\
        $config \\
        $args \\
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """

    stub:
    """
    touch multiqc_data
    touch multiqc_plots
    touch multiqc_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}
