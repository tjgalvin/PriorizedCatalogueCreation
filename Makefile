# Files containing the name/path of each of the reference and sub band images
REFIMG=reference_images.dat
SUBIMG=subband_images.dat
MASTER=master_catalogue.fits

SUBS=$(shell cat $(SUBIMG))
REFS=$(shell cat $(REFIMG))


all:
	echo $(REFS) $(SUBS)

# Fake rules to indicate that these files should be assumed to exist
$(REFS) $(REFS:.fits=_psf.fits):
$(SUBS) $(SUBS:.fits=_psf.fits):

# This rule expands to "ref1_comp.fits: ref1.fits ref1_bkg.fits", for each file in $(REFS)
#$(REFS:.fits=_comp.fits): $(REFS) $(REFS:.fits=_bkg.fits)
#	echo $@ $< $^


# Background and noise maps for the sub images
$(SUBS:.fits=_bkg.fits): %_bkg.fits : %.fits
	echo BANE $<
# This duplication is required since I can't mash it into the above rule whislt also using target:pattern:prereq
# However it causes BANE to run twice so we first check to see if the file is already built. arg!
$(SUBS:.fits=_rms.fits): %_rms.fits : %.fits
	test -f $@ || echo BANE $<

# Background and noise maps for the reference images
$(REFS:.fits=_bkg.fits): %_bkg.fits : %.fits
	echo BANE $<
$(REFS:.fits=_rms.fits): %_rms.fits : %.fits
	test -f $@ || echo BANE again $<



# Blind source finding on reference images
$(REFS:.fits=_comp.fits): %_comp.fits : %.fits %_bkg.fits %_rms.fits %_psf.fits
	echo aegean $< --background $*_bkg.fits --noise $*_rms.fits --psf $*_psf.fits --island --table $<,$*.reg

# Quality control on reference image catalogues
$(REFS:.fits=_QC_comp.fits): $(REFS:.fits=_comp.fits)
	echo python QC_filter --infile $< --outfile $@


# Join all the reference catalogues together to make one master catalogue
$(MASTER): $(REFS:.fits=_QC_comp.fits)
	echo "cat $^ -> $@"

# priorized fitting on reference catalogues
$(SUBS:.fits=_proirized_comp.fits): %_priorized_comp.fits : %.fits %_bkg.fits %_rms.fits %_psf.fits $(MASTER)
	echo aegean $*.fits --background $*_bkg.fits --noise $*_rms.fits --psf $*_psf.fits --table $<,$*.reg --priorize 2 --input $(MASTER)
