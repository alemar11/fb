# Test 1

Different images with the same name are stored inside Images.xcassets like so:

- Folder/smurf
- NamespacedFolder/smurf
- smurf

The only genereated ImageResource is from the one inside "Folder" 

# Test 2

Different images with different names are stored inside Images.xcassets like so:

- Folder/smurf3
- NamespacedFolder/smurf1
- smurf2

ImageResources are generated only for smurf3 and smurf2, but not for smurf1