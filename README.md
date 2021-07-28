# PriorizedCatalogueCreation
Workflow for creating catalogues from a set of multi epoch or multi frequency images.

This fork of the original Priorized Catalogue Creation repository contains some extra steps that are specific to the GLEAM-X processing pipeline. Specifically, this version will derive a global scalar brightness correction, which is derived for each sub-band against the GLEAM Global Sky Model (GGSM). 

The rescaling stage will create additional data-products, with the 'rescaled' string contained in the filenames. The original images and catalogues produced are not modified. New images and catalogues will be created. 
