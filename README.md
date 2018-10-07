# data_workflow_paper
# Hackett RA, Belitz MW, Cahill BC, ...Monfils, AK (in prep) Title. Journal. Volume: Pages.
# Comments included in R code file
# To start you need: 
## 1. A folder containing the photos you wish to copy or rename
## 2. A .csv file containing three columns:
##      ID - An identifier to use as the prefix of the new image filename
##      PhotoStart - The current filename of first image of the sequence to be copied or renamed. The last characters of the filename should be numerals
##      PhotoEnd - The current filename of the last image of the sequence to be copied or renamed. If only one image in the sequence, it will be the same value as PhotoStart
##   The names in the column should not have a filename suffix (e.g., .jpg)
## 3. A destination folder for copied images
