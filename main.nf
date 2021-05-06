#! /usr/bin/env nextflow

version = '0.9'
date = '2021-05-03'
/* CONFIGURATION STAGE */

// output directory
params.output_dir = "${baseDir}/results/"

params.reference_catalogue = "none"

log.info """\
         GLEAM-X Catalogue Creation
         ==========================
         version      : ${version} - ${date}
         night        : ${params.night}
         images from  : ${params.image_file}
         ref cat      : ${params.reference_catalogue}
         cat file     : ${params.catalogue_file}
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
  .splitCsv(header:true, strip:true)
  .map{row -> tuple(file("${params.image_dir}/${row.image}"),
                    file("${params.image_dir}/${row.bkg}"), 
                    file("${params.image_dir}/${row.rms}"), 
                    file("${params.image_dir}/${row.psf}"), 
                    "${row.name}") }

process source_find {
  label 'aegean'

  input:
  tuple path('image.fits'), path('bkg.fits'), path('rms.fits'), path('psf.fits'), val(name) from image_ch
  file('reference.fits') from file(params.reference_catalogue)

  output:
  path("${name}_comp.fits") into catalogue_ch

  script:
  """
  echo ${task.process} on \${HOSTNAME}
  aegean --cores ${task.cpus} --background bkg.fits --noise rms.fits --psf psf.fits\
  	 --noregroup --table image.fits --priorized 1 --input reference.fits\
         image.fits
  mv image_comp.fits ${name}_comp.fits
  """
}

process join_catalogues {
  input:
  path(images) from catalogue_ch.collect()
  file('catalogues.csv') from file(params.catalogue_file)
  file('reference.fits') from file(params.reference_catalogue)

  output:
  path("${params.night}_joined_cat.vot") into wide_cat_ch

  script:
  """
  echo ${task.process} on \${HOSTNAME}
  python ${params.codeDir}/join_catalogues.py --epochs catalogues.csv --refcat reference.fits --out ${params.night}_joined_cat.vot
  """
}
