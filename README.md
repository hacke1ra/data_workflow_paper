# data_workflow_paper
# Hackett RA, Belitz MW, Gilbert E, Monfils, AK (in prep) A data management workflow of biodiversity data from the field to data users. Applications in Plant Science. Volume: Pages.
# Comments included in R code file
# To start you need: 
## 1. A folder containing the photos you wish to copy or rename
## 2. A .csv file containing three columns:
##      ID - An identifier to use as the prefix of the new image filename
##      PhotoStart - The current filename of first image of the sequence to be copied or renamed. The last characters of the filename should be numerals
##      PhotoEnd - The current filename of the last image of the sequence to be copied or renamed. If only one image in the sequence, it will be the same value as PhotoStart
##   The names in the column should not have a filename suffix (e.g., .jpg)
## 3. A destination folder for copied images
<hr>
<p>The code will rename field image files sequntially to a unique HumanObservation or PreservedSpecimen record. Those for PreservedSpecimens will be renamed with the catalogNumber (i.e. Barcode) then sequentially throught the alphabet (up to 26 field images): CMC00104557_A; CMC00104557_B. Those for HumanObservations will be by eventID (e.g., LLF14) as the prefix for new file names. Images will be renamed in their original location and copied to a destination of your choosing.</p>

<p>The code will also write a .txt table that contants the original location and name of the image, its desination and new name, and whether the file copying or renaming was successful. This table will be located in the OriginalLocation and have the prefix: Table_of_from-to_image_filenames_and_action_success_. </p>

<p>For HumanObservation images, another table will be made and saved in the OriginalLocation as well. This table is set up to be appeneded to a table in the MS Access Database using the "Procedure-Creating_Records_for_Symbiota–Linking_HumanObservation_to_Field_Images.docx". </p>
