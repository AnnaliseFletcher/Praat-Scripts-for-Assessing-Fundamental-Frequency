# This script goes through sound and TextGrid files in a directory,
# opens each pair of Sound and TextGrid and extracts:
#
#       *** pitch listings from only the blank segments
#       
#       and saves results to a text file.
#
#   NOTE:  run separately for male and female  
# This script is originally based on 'collect_pitch_data_from_files
# distributed under the GNU General Public License.
# Copyright 4.7.2003 Mietta Lennes


## change the paths.....
form Analyze vowel labeled segments in files
	comment Directory of sound files
	text sound_directory: 
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files
	text textGrid_directory: 
	sentence TextGrid_file_extension .TextGrid
	comment Enter segment tier name
	sentence segTier PitchErrors
	comment Full path of the resulting text file
	text resultfile: 
	comment REMEMBER TO RUN MALES AND FEMALES SEPARATELY
	
		
endform

# Here, you make a listing of all the sound files in a directory.


Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Check if the result file exists:
if fileReadable (resultfile$)
	pause The result file 'resultfile$' already exists! Do you want to overwrite it?
	filedelete 'resultfile$'
endif

# Write a row with column titles to the result file:
# (remember to edit this if you add or change the analyses!)

titleline$ = "File,label,meanpitch,time,begs,ends,duration'newline$'"
fileappend "'resultfile$'" 'titleline$'

number_of_intervals = 0

# Change max formant and max/min pitch based on sex
	
		minPitch = 50
		maxPitch = 300
	endif


# Go through all the sound files, one by one:

for ifile to numberOfFiles
	select Strings list
	filename$ = Get string... ifile

	# A sound file is opened from the listing:
	Read from file... 'sound_directory$''filename$'

	# Starting from here, you can add everything that should be 
	# repeated for every sound file that was opened:

	soundname$ = selected$ ("Sound", 1)


	utt$ = soundname$
	select Sound 'utt$'
	To Pitch (filtered ac)... 0.0 50 600 15 0 0.03 0.09 0.5 0.055 0.35 0.14

	# Open a TextGrid by the same name:
  
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
	
     	 
	
	
	call GetTier 'segTier$' seg
	number_of_intervals = Get number of intervals... 1

		
	# step through the intervals.
	for j from 1 to number_of_intervals
		select TextGrid 'utt$'
    		label$ = Get label of interval... seg j
		# if the label is blank, swap for something that won't map to text
		if label$ = ""
			label$ = "X"
		endif
		

		# now look for label$ in list of labels
		mapToP = index("X",label$)
		
		# if it's not a pitch error...
    		if mapToP
			     begs = Get starting point... seg j                 
			     ends = Get end point... seg j
			     duration = ends - begs

	
			# get pitch values from segment
			      select Pitch 'utt$'
			 		no_of_frames = Get number of frames

				for frame from 1 to no_of_frames
				    time = Get time from frame number: frame
				    pitch = Get value in frame: frame, "Hertz"
				#fileappend "'resultfile$'" 'resultline$'
				    #appendFileLine: "pitch_list.txt", "'time','pitch'"
				    	if time >= begs and time <= ends
						resultline$ = " 'utt$','label$','pitch','time', 'begs','ends', 'duration''newline$'"
								fileappend "'resultfile$'" 'resultline$'
					endif
				endfor
		

				# Save result to text file:
			#	resultline$ = " 'utt$','label$','pitch','time', 'begs','ends', 'duration''newline$'"
			#	fileappend "'resultfile$'" 'resultline$'
				
		endif
	endfor

		

	endif
	# Remove the temporary objects from the object list
	# and go on with the next sound file!
	select TextGrid 'soundname$'
	Remove
	select Sound 'soundname$'
	Remove
select Pitch 'soundname$'
	Remove
endfor

select Strings list
Remove
pause Done!

#-------------
# This procedure finds the number of a tier that has a given label.

procedure GetTier name$ variable$
        numberOfTiers = Get number of tiers
        itier = 1
        repeat
                tier$ = Get tier name... itier
                itier = itier + 1
        until tier$ = name$ or itier > numberOfTiers
        if tier$ <> name$
                'variable$' = 0
        else
                'variable$' = itier - 1
        endif

	if 'variable$' = 0
		exit The tier called 'name$' is missing from the file 'soundname$'!
	endif

endproc
