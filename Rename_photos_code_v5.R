##################################################
##################################################
## This code will rename field image files sequntially to a unique 
## HumanObservation or PreservedSpecimen record. Those for PreservedSpecimens
## will be renamed with the catalogNumber (i.e. Barcode) then sequentially 
## throught the alphabet (up to 26 field images): CMC00104557_A; CMC00104557_B. 
## Those for HumanObservations will be by eventID (e.g., LLF14) as the 
## prefix for new file names. Images will be renamed in their original
## location and copied to a destination of your choosing.
##
## You will need a .csv file containing the unique identifier
## (i.e., catalogNumber, eventID) and the current filename for the 
## first image in the sequence (e.g., PhotoStart) and last image in the
## sequence (e.g., PhotoEnd). This can be exported from the MS Access database 
## (K:/Research/monfi1ak/PlantSystematics/Research Projects/Hackett2011/Data/Hackett-data)
## to your destination folder. The columns must be named "ID" for the unique identifier
## column, "PhotoStart" for the first image filename in the sequence, and "PhotoEnd" for
## the last image filename in the sequence.
##
## You will also need the file path to the folder containing the
## originally named images. The old image names should be sequential.
##
## This code will also write a .txt table that contants the original location
## and name of the image, its desination and new name, and whether the file
## copying or renaming was successful. This table will be located in the 
## OriginalLocation and have the prefix: Table_of_from-to_image_filenames_and_action_success_. 
##
## For HumanObservation images, another table will be made and saved in the
## OriginalLocation as well. This table is set up to be appeneded to a table in the 
## MS Access Database using the "Procedure-Creating_Records_for_Symbiota–Linking_HumanObservation_to_Field_Images.docx". 
######################################################
#######################################################


#####################################################
#####################################################
## Load data, set variables - edit select lines below as indicated
####################################################
####################################################
#change working directory to ...
setwd("/Volumes/data/Research/monfi1akLab/PlantSystematics/Research Projects/Lab_data/Prairie_Fen_Related/Data/Photos") ## This is the location you are working in. Usually the folder containing your photos. If using PC, you must have double-slashes (//) or backwards slash(\) between each folder

#INSTALL packages:
library(stringr)  #to pull characters from the right
library(plyr) #to format HumanObservation list of image names correctly
library(jpeg) #to compress large .jpeg

##################
#Load data
mydata <- read.csv("RenameFieldImages/BASE/QualityControl-RenameFieldImageFiles_IRQ2013_CMC.csv", header=TRUE) # This is the location of the file from your worksing directory. What you exported from MS Access and saved as .csv. If using PC, you must have double-slashes (//) or backwards slash(\) between each folder
if(all(substr(mydata$ID,1,3) == "CMC")){ #prefix of the catalogueID
 	basisOfRecord <- "PreservedSpecimen"
 }else{
 	basisOfRecord <- "HumanObservation"
 	mydata.image.names <- as.list(mydata$ID)
 	names(mydata.image.names) <- mydata$ID
 	}

#################
## Set other variables
OriginalLocation <- file.path("2013Hackett") #Where are your images now? (folders)

DestinationLocation <- file.path("FieldImages20170712") #Where are they going? (folders)

image.file.type <- ".jpg" #what is the extention on the images. All images must be the same.
image.size.threshold <- 3 # Largest file size you want your images in megabytes (MB) 
image.quality <- 0.70 # Percentage that you want the destination image compressed if file size is greater than threshold above. 70% was Symbiota's Ed Gilbert recommendation. If you want no compression, use 1.00

URL <- "http://plantdata.bio.cmich.edu/symbiota_grab/" ##Where will the renames images be uploaded to the server. End with "/"

n.end.char <- 4 # number of numeric characters to pull from end of current filename string to calculate the number of photos in the sequence

rename.in.original.folder <- FALSE ##Either TRUE or FALSE. If you want to rename the file in the original folder, choose TRUE. This means that you will be unable to locate the image by the old filename from now on. If you only want to keep the original filename in the original folder, choose FALSE.

copy.to.new.folder <- TRUE ##Either TRUE or FALSE. If you want to copy the file from the OriginalLocation to the DestinationLocation, choose TRUE. If you only want to rename the files at this time, select FALSE.


###################################################
###################################################
### Copy images to new filenames - no need to read further
###################################################
###################################################
origin.exists <- file.exists(OriginalLocation) #Checks to make sure origin folder exists
destination.exists <- file.exists(DestinationLocation) #Checks to make sure destination folder exists

if(copy.to.new.folder){
	action <- "Copied"
}else if(rename.in.orginal.folder){
	action <- "Renamed"
}

if(all(destination.exists,origin.exists)){
	# Make matrix to hold from and to filenames, locations, and whether it was successful
	file.from.to.table <- matrix(data=NA, nrow=0, ncol=4)
for(i in 1:nrow(mydata)){ #goes through each row of mydata
	start.no <- str_sub(mydata$PhotoStart[i], start=-n.end.char)
	end.no <- str_sub(mydata$PhotoEnd[i], start=-n.end.char)
	n.images <- as.numeric(end.no) - as.numeric(start.no) + 1
	if(n.images >= 1){ # put a higher limit on for errors in filenames?
			if(basisOfRecord == "HumanObservation"){
				mydata.image.names.temp <- vector(mode="logical")				
			}
		for(j in 1:n.images){ #goes through to rename each image file in sequence
			n.char <- nchar(as.numeric(start.no))
			original.begins <- str_sub(mydata$PhotoStart[i], start=1, end=-(n.end.char+1)) #first part of filename, unchaged among images
			original.ends <- as.numeric(start.no) + (j-1) #will sequentially add to end of filename			
			n.char <- nchar(original.ends)
			original.ends <- paste0(paste0(rep("0", each = n.end.char - n.char),collapse=""),original.ends) #addes "0" to beginning if start.no < 1000	
			
			original.path <- file.path(OriginalLocation, paste0(original.begins, original.ends, image.file.type))
			original.path.exist <- file.exists(original.path) ### If a false value is returned, the original.path file doesn't exist
				
				if(original.path.exist){
					renamed.image <- paste0(mydata$ID[i], "_", LETTERS[j], image.file.type)
					## Rename image in original folder if below is TRUE
					if(rename.in.original.folder){ 
						destination.image.path <- file.path(OriginalLocation, renamed.image)
								
						print(paste0(original.path, " to ", destination.image.path))
						file.rename(from = original.path, to = destination.image.path)
						file.from.to.table <- rbind(file.from.to.table, c(as.character(mydata$ID[i]), original.path, destination.image.path, TRUE))				

						original.path <- destination.image.path	
					}
					
					##Copy Image
					if(copy.to.new.folder){
						destination.image.path <- file.path(DestinationLocation, renamed.image)
						print(paste0(original.path, " to ", destination.image.path))
						file.copy(from=original.path, to=destination.image.path)
						file.from.to.table <- rbind(file.from.to.table, c(as.character(mydata$ID[i]), original.path, destination.image.path, TRUE))			
					}
						
					## build list of image.names for HumanObservation fields
					if(basisOfRecord == "HumanObservation"){
						mydata.image.names.temp[j] <- paste0(URL, destination.image.path, ";")
					}
						
					### Compress image if files size > image.size.threshold
					if(file.size(destination.image.path) > (image.size.threshold*1000000)){
						full.image <- readJPEG(original.path)
						writeJPEG(full.image, target=destination.image.path, quality=image.quality)
					}
				}else{
					writeLines(c("",paste0("The original photo you wish to copy does not exist for ", mydata$ID[i], ": ", original.path),""))
					file.from.to.table <- rbind(file.from.to.table, c(as.character(mydata$ID[i]), original.path, "", FALSE))				
				}
				}
		if(basisOfRecord == "HumanObservation"){
			mydata.image.names[[i]] <- mydata.image.names.temp
			}
	}else if(n.images <= -9900){ #images cross over 1000 mark; may have greater range
		print("Images cross over 1000 mark (e.g., PhotoEnd=P1050005 & PhotoStart=P1049998) >> n.images=-9993")
		## This code maybe substituded for str_sub code above, but I don't know about errors in case there are mixed numerals and characters in the string (e.g. DSC88AB0999)
		start.no <- gsub("[^0-9]", "", mydata$PhotoStart[i])
		end.no <- gsub("[^0-9]","", mydata$PhotoEnd[i])
		n.images <- as.numeric(end.no) - as.numeric(start.no) + 1
		n.char1 <- nchar(start.no) #number of characters
		if(n.images >= 1){ # put a higher limit on for errors in filenames?
			if(basisOfRecord == "HumanObservation"){
				mydata.image.names.temp <- vector(mode="logical")				
			}
			for(j in 1:n.images){ #goes through to rename each image file in sequence
				n.char <- nchar(as.numeric(start.no))
				original.begins <- str_extract(mydata$PhotoStart[i], "[A-Z]+") #characters of filename, unchanged among images, assumed to be at the beginning of filename
				original.ends <- as.numeric(start.no) + (j-1) #will sequentially add to end of filename			
				n.char <- nchar(original.ends)				
				original.ends <- paste0(paste0(rep("0", each = nchar1 - n.char),collapse=""),original.ends) #addes "0" to beginning if start.no begins with "0" as string	
			
				original.path <- file.path(OriginalLocation, paste0(original.begins, original.ends, image.file.type))
				original.path.exist <- file.exists(original.path) ### If a false value is returned, the original.path file doesn't exist
				
				if(original.path.exist){
					renamed.image <- paste0(mydata$ID[i], "_", LETTERS[j], image.file.type)
					## Rename image in original folder if below is TRUE
					if(rename.in.original.folder){ 
						destination.image.path <- file.path(OriginalLocation, renamed.image)
						print(paste0(original.path, " to ", destination.image.path))
						file.rename(from = original.path, to = destination.image.path)
						file.from.to.table <- rbind(file.from.to.table, c(as.character(mydata$ID[i]), original.path, destination.image.path, TRUE))			
							
						original.path <- destination.image.path
					}					 
					
					##Copy Image
					if(copy.to.new.folder){
						destination.image.path <- file.path(DestinationLocation, renamed.image)
						print(paste0(original.path, " to ", destination.image.path))
						file.copy(from=original.path, to= destination.image.path)
						file.from.to.table <- rbind(file.from.to.table, c(as.character(mydata$ID[i]), original.path, destination.image.path, TRUE))				
					}
					
					## build list of image.names for HumanObservation fields
					if(basisOfRecord == "HumanObservation"){
						mydata.image.names.temp[j] <- paste0(URL,  copy.image.path, ";")
					}
					
					### Compress image if files size > image.size.threshold
					if(file.size(destination.image.path) > (image.size.threshold*1000000)){
						full.image <- readJPEG(original.path)
						writeJPEG(full.image, target=destination.image.path, quality=image.quality)
					}
				}else{
					writeLines(c("",paste0("The original photo you wish to copy does not exist for ", mydata$ID[i], ": ", original.path),""))
					file.from.to.table <- rbind(file.from.to.table, c(as.character(mydata$ID[i]), original.path, "", FALSE))				
				}		
		}
		if(basisOfRecord == "HumanObservation"){
			mydata.image.names[[i]] <- mydata.image.names.temp
			}
		}else if(n.images < 1){
			print("Error in n.images <= -9900/n.images >=1 ifelse. Likely an error with original filename")
		}	
	}else if(all(n.images < 1, n.images > -9900)){
		print("Error in image sequence loop 'i' ifelse. n.images is < 1.")
		break
	}else if(n.images == "NA"){print("Error in 'n.images'. Check filenames in Photo columns for possible error.")}else{print("Error in 'n.images'.")}	
}


## Write and save table with original and new filenames and locations and if action was successful
colnames(file.from.to.table) <- c("ID", "From", "To", action)
write.table(file.from.to.table, file=file.path(OriginalLocation, paste0("Table_of_from-to_image_filenames_and_action_success_", format(Sys.Date(), "%Y%m%d"), "_", format(Sys.time(), "%H-%M"), ".txt")), col.names=TRUE, row.names=FALSE, sep="\t")

##for HumanObservations, make table of mydata.image.names
if(basisOfRecord == "HumanObservation"){
	mydata.image.names <- as.matrix(ldply(mydata.image.names, rbind, .id="ID"))
	mydata.image.names[is.na(mydata.image.names)] <- ""
	colnames(mydata.image.names)[1] <- "eventID"
	write.table(mydata.image.names, file=file.path(OriginalLocation, paste0("Table_of_eventID_images_", format(Sys.Date(), "%Y%m%d"), "_", format(Sys.time(), "%H-%M"), ".txt")), col.names=TRUE, row.names=FALSE, sep="\t")
}
}else{	
	if(destination.exists){
		print("Your origin folder doesn't exist.")
	}else if(origin.exists){
		print("Your destination folder doesn't exist.")
	}else{
		print("Neither your origin nor destination folders exist.")
	}
}	

##################
###When complete, go through list above or Table_of_from-to_image_filenames_and_action_success_ in OriginalLocation to check those images that didn't copy.




