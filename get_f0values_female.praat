timeStep = 0.01
minimum_pitch = 50
maximum_pitch = 600
input_directory$ = 
output_directory$ = 
file_type$ = "wav"

fileList = do("Create Strings as file list...", "list", input_directory$ + "/*." + file_type$)
numberOfFiles = do("Get number of strings")

for i to numberOfFiles

  selectObject(fileList)
  filename$ = do$("Get string...", i)
  soundObject =  do("Read from file...", input_directory$ +"/" + filename$)

  pitchObject = do("To Pitch (filtered ac)...", 0.0, 50, 600,15,0,0.03,0.09,0.5,0.055,0.35,0.14)
  removeObject(soundObject)
  tableObject = do("Create Table with column names...", "table", 0, 
      ..."file time meanpitch")

  selectObject(pitchObject)
  numberOfFrames = do("Get number of frames")
  for frame to numberOfFrames

    select pitchObject
    f0 = do("Get value in frame...", frame, "Hertz")
    time = do("Get time from frame number...", frame)

    selectObject(tableObject)
    do("Append row")
    thisRow = do("Get number of rows")
    do("Set numeric value...", thisRow, "time", time)
    do("Set numeric value...", thisRow, "meanpitch", f0)
	do("Set string value...", thisRow, "file", filename$)

  endfor

  filename$ = filename$ - ("." + file_type$)
  do("Write to table file...", output_directory$ + "/" + filename$ + ".txt")
  removeObject(tableObject, pitchObject)
endfor