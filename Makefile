# Files containing the name/path of each of the reference and sub band images
REFIMG="reference_images.dat"
SUBIMG="subband_images.dat"

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


# Background and noise maps
$(SUBS:.fits=_bkg.fits) $(SUBS:.fits=_rms.fits): $(SUBS)
	echo BANE $<

$(REFS:.fits=_bkg.fits) $(REFS:.fits=_rms.fits): $(REFS)
	echo BANE $<


# Blind source finding on reference images
$(REFS:.fits=_comp.fits): $(REFS) $(REFS:.fits=_bkg.fits) $(REFS:.fits=_rms.fits) $(REFS:.fits=_psf.fits)
	echo aegean $< --background $(word 2, $^) --noise $(word 3, $^) --psf $(word 4, $^) --island --table $<,$(subst .fits,.reg,$<)

# Quality control on reference image catalogues
$(REFS:.fits=_QC_comp.fits): $(REFS:.fits=_comp.fits)
	echo python QC_filter --infile $< --outfile $@
