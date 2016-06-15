# This script downloads and installs MCG Samples for 3ds Max 2017 from GitHub
# The sample tools, compounds, and scenes are downloads and unzipped to 
# %userprofile%\Autodesk\3ds Max 2017\Max Creation Graph\Tools\MCG Samples
# DO NOT edit those files or folder, as they will be deleted whenever this script is run. 

import os, urllib, zipfile, time, shutil

def downloadFileAndUnzip(url, directory):
	if not os.path.exists(directory):
		os.makedirs(directory)
	dest = os.path.join(directory, os.path.basename(url))	
	urllib.urlretrieve(url, dest)
	zip = zipfile.ZipFile(dest)
	zip.extractall(directory)

def samplesUrl():
	return "https://github.com/ADN-DevTech/3dsMax-MCG-Samples/archive/master.zip"

def downloadSamples():
	return dest
	
def mcgUserFolder():
	return os.path.join(os.environ['USERPROFILE'], 'Autodesk', '3ds Max 2017', 'Max Creation Graph')
	
def mcgToolsFolder():
	return os.path.join(mcgUserFolder(), 'Tools')
	
def mcgSamplesTargetFolder():
	return os.path.join(mcgToolsFolder(), 'MCG Samples')
	
def deleteFolder(path):
	# Could fail if read-only access is set on a file.
	# http://stackoverflow.com/questions/2656322/python-shutil-rmtree-fails-on-windows-with-access-is-denied
	if not os.path.exists(path): 
		return
	shutil.rmtree(path)

def fetchSamples():
	url = samplesUrl()
	directory = mcgSamplesTargetFolder()
	if os.path.exists(directory):
		deleteFolder(directory)
	downloadFileAndUnzip(url, directory)
		
def zipFolder(path, zipFileName):
	if not os.path.exists(path): 
		return
	baseDir = os.path.dirname(path)
	zip = zipfile.ZipFile(zipFileName, 'w', zipfile.ZIP_DEFLATED)
	for root, dirs, files in os.walk(path):
		for file in files:
			zip.write(os.path.join(root, file))
	zip.close()

    	
fetchSamples()
