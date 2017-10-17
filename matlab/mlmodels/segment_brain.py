#!/usr/bin/python
import argparse
import numpy as np
import os
import lightgbm as lgb
import time
from sklearn.metrics import mean_squared_error
from sklearn.metrics import confusion_matrix
import fnmatch

	
def GetFeatureDimensions(feature_type):
	if feature_type == 'gabor':
		dd = 288
	elif feature_type == 'int':
		dd = 4
	else:
		print('Feature type not recognized')
	
	return dd

def FindBrainFeatures(feature_dir,brain_name,feature_type):
	for file in os.listdir(feature_dir):
		if fnmatch.fnmatch(file,brain_name+'*'+feature_type+'*.bin'):
			return file
	print('No such file found')
	return 0

def FindBrainIdx(feature_dir,brain_name,feature_type):
	for file in os.listdir(feature_dir):
		if fnmatch.fnmatch(file,brain_name+'*idx*.bin'):
			return file
	print('No such file found')
	return 0

def LoadModelFile(model_dir,mdl_type,feature_type):
	dd = GetFeatureDimensions(feature_type)
	for file in os.listdir(model_dir):
		if fnmatch.fnmatch(file,mdl_type+'*lgbm*'+str(dd)+'*.txt'):
			lgb_model = lgb.Booster(model_file=(model_dir + file))
			return lgb_model
	print('No such file found')
	return 0

def LoadSingleBinaryFile(fileloc,dd=None):
	ff = open(fileloc,'r')
	A = np.fromfile(ff,dtype=np.float32)
	if dd is not None:
		A = A.reshape( (-1,dd),order='F')
	else:
		A = A.flatten()
	ff.close()
	return A

def Classify(brain_name,mdl_type,test_name,feature_type='gabor'):
	test_dir = os.environ['BRATSDIR'] + '/classification/'+ test_name + '/'
	out_dir = os.environ['BRATSDIR'] + '/userbrats/BRATS17tharakan/'+test_name+'_results/lgbm_results/'
	
	print('Brain name: ' + brain_name)
	print('Model type: ' + mdl_type + ' w/ ' + feature_type)

	dd = GetFeatureDimensions(feature_type)
	
	# load model
	start = time.time()
	model_dir = os.environ['BRATSDIR'] + '/classification/training/models/' 
	lgb_model = LoadModelFile(model_dir,mdl_type,feature_type)
	print(' Model load took ' + str(time.time() - start) )
	
	# load brain to predict on 
	start = time.time()
	brain_file = FindBrainFeatures(test_dir,brain_name,feature_type)
	Xtest = LoadSingleBinaryFile(test_dir + brain_file,dd)
	nt = Xtest.shape[0]
	print(' Test load of ' + str(nt) + ' data points took ' + str(time.time() - start) )
	
	# predict
	start = time.time()
	class0probs = lgb_model.predict(Xtest) 
	print(' Test predict took ' + str(time.time() - start) )
	
	# load index file
	#idx_file = FindBrainIdx(test_dir,brain_name,'idx')
	#feat_idx = LoadSingleBinaryFile(test_dir + idx_file)
	
	# save to some kind of binary?
	outfile = out_dir + brain_name + '.probs.lgbm.' + mdl_type + '.' + feature_type + '.bin'
	class0probs.astype('float32').tofile(outfile)
	
def Predict(mdlfile,brain_file,outfile,dd):
	
	print('Data: ' + brain_file);
	print('Mdl: ' + mdlfile);
	print('Svloc: ' +  outfile);

	start = time.time()	
	lgb_model = lgb.Booster(model_file=(mdlfile));
	print(' Model load took ' + str(time.time() - start) )
	
	# load brain to predict on 
	start = time.time()
	ff = open(brain_file,'r')
	Xtest = np.fromfile(ff,dtype=np.float32)
	Xtest = Xtest.reshape( (-1,dd),order='F')
	nt = Xtest.shape[0]
	print(' Test load of ' + str(nt) + ' data points took ' + str(time.time() - start) )

	# predict
	start = time.time()
	class0probs = lgb_model.predict(Xtest) 
	print(' Test predict took ' + str(time.time() - start) )

	# Save to file
	class0probs.astype('float32').tofile(outfile)

def Launcher(section_id,tot_sections):
	feature_type = 'gabor'
	dd = 288;
	brats = os.environ['BRATSDIR']
	test_brain_dir = brats + '/preprocessed/augTestData/meanrenorm/'
	files = os.listdir(test_brain_dir)
	test_feat_dir = brats + '/classification/meanrenorm/meanrenormTst/';
	mdl_dir = brats + '/classification/training/models/';
	mdlfile = mdl_dir + 'ENvNE.lgbm.renorm.i40.txt';
	mdl_save_dir = os.environ['SCRATCH'] + '/meanrenormTst_results/';
	mdl_save_str = 'probs.lgbmrenorm.ENvNE';

	for bi in range(len(files)):
		brain = files[bi]

		brain_str = FindBrainFeatures(test_feat_dir,brain,feature_type);


		if ( ( (bi) % tot_sections) == section_id) and (brain_str != 0): 
			brain_file = test_feat_dir + brain_str;
			out_file = mdl_save_dir + brain + '.' + mdl_save_str + '.' + feature_type + '.bin';
			#Classify(brain,'NOvWT',test_name)
			#Classify(brain,'EDvTC',test_name)
			#Classify(brain,'ENvNE',test_name)
			Predict(mdlfile,brain_file,out_file,dd);

def main():
	parser = argparse.ArgumentParser()

	#parser.add_argument('mdl_num', type=int, help='model ID',default=1)
	parser.add_argument('section_id', type=int, help='ID for this task',default=1)
	parser.add_argument('tot_sections', type=int, help='Total number of tasks',default=2)

	args = parser.parse_args()
	
	Launcher(args.section_id,args.tot_sections)

if __name__ == '__main__':
	main()
