#! /usr/bin/env nextflow

version = '0.9'
date = '2021-03-24'
/* CONFIGURATION STAGE */

// output directory
params.output_dir = "${baseDir}/results/"

params.reference_catalogue = "none"

log.info """\
         GLEAM-X Catalogue Creation
         ==========================
         version      : ${version} - ${date}
         images from  : ${params.image_file}
         ref cat      : ${params.reference_catalogue}
         output to    : ${params.output_dir}
         --
         run as       : ${workflow.commandLine}
         config files : ${workflow.configFiles}
         container    : ${workflow.containerEngine}:${workflow.container}
         """
         .stripIndent()

// Read the image names from a text file
image_ch = Channel
  .fromPath(params.image_file)
  .splitCsv(header:true)
  .map{row -> tuple(file("${params.image_dir}/${row.image}"),
                    file("${params.image_dir}/${row.bkg}"), 
                    file("${params.image_dir}/${row.rms}"), 
                    file("${params.image_dir}/${row.psf}"), 
                    "${row.name}") }
  .first()

process source_find {
  label 'aegean'

  input:
  tuple path('image.fits'), path('bkg.fits'), path('rms.fits'), path('psf.fits'), val(name) from image_ch
  file('reference.fits') from file(params.reference_catalogue)

  output:
  path("${name}_comp.fits")

  script:
  """
  echo ${task.process} on \${HOSTNAME}
  aegean --cores ${task.cpus} --background bkg.fits --noise rms.fits --noregroup\
         --table image.fits --priorized 1 --input reference.fits image.fits
  mv image.fits ${name}_comp.fits
  """
}