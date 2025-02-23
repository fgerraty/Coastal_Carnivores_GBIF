##########################################################################
# Coastal Carnivores Project #############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 00: Load packages ###############################################
#-------------------------------------------------------------------------

# Part 1: Load Packages --------------------------------------------------

# Load packages
packages <- c("tidyverse", "sf", "lwgeom", "rgbif")

pacman::p_load(packages, character.only = TRUE); rm(packages)

