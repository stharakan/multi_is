#!/usr/bin/python
import numpy as np
import os
import lightgbm as lgb
import time
from sklearn.metrics import mean_squared_error
from sklearn.metrics import confusion_matrix


def main(mdl_type):
	# Load training data
	train_dir = os.environ['BRATSDIR'] + '/userbrats/BRATS17tharakan/meanrenorm/'
	train_labs = 'BRATS_50M_meanrenorm.dd.288.yy.bin';
	train_data = 'BRATS_50M_meanrenorm.dd.288.XX.bin';
	dd = 288;
	nn = -1; 

	#test_dir = os.environ['BRATSDIR'] + '/classification/Brats17TrainingDataSample/'
	test_dir = train_dir;
	test_data = 'Brats17_TCIA_645_1.nn.1493095.dd.288.gabor.bin';
	test_labs = 'Brats17_TCIA_645_1.nn.1493095.labs.bin';
	nt = -1

	use_validation = True;
	
	# Model parameters
	iters = 40;
	params = {
		'task':'training',
		'num_leaves':1023, 
		'max_depth':15,
		'max_bin':1023,
		'application':'binary',
		'metric': 'binary_logloss',
		'boosting_type': 'gbdt',
		'min_data_in_leaf':0,
		'verbose':0,
		'min_sum_hessian_in_leaf':100}

	
	# Training 
	print(' Load training ')
	start = time.time()
	
	ff = open(train_dir + train_data,'r')
	Xtrain = np.fromfile(ff,dtype=np.float32)
	Xtrain = Xtrain.reshape( (nn,dd),order='F')
	nn = Xtrain.shape[0];
	
	ff = open(train_dir + train_labs,'r')
	Ytrain = np.fromfile(ff,dtype=np.float32)
	Ytrain = Ytrain.flatten( )
	
	# Reset Ytrain
	Xtrain,Ytrain = SetData(Xtrain,Ytrain,mdl_type)
	
	end = time.time();
	print(' Train took ' +  str(end-start) ) 
	
	if not use_validation:
		# Run training classifier
		TrainClassifier(Xtrain,Ytrain,params,mdl_type,iters)
	else:
		# Testing
		print(' Load test ')
		start = time.time()
		
		ff = open(test_dir + test_data,'r')
		Xtest = np.fromfile(ff,dtype=np.float32)
		Xtest = Xtest.reshape( (nt,dd),order='F')
		
		ff = open(test_dir + test_labs,'r')
		Ytest = np.fromfile(ff,dtype=np.float32)
		Ytest = Ytest.flatten( )
		Xtest,Ytest = SetData(Xtest,Ytest,mdl_type)
		nt = Xtest.shape[0]

		end = time.time()
		print(' Test took ' +  str(end - start) ) 
			
		# Run classifier
		TrainClassifierWithVal(Xtrain,Ytrain,params,mdl_type,iters,Xtest,Ytest)


def SetLabels(Ytrain,mdl_type):
	tot_idx = np.array( range(len(Ytrain)) )
	nzidx = Ytrain != 0
	if mdl_type == 'NOvWT':
		Ytrain[nzidx] = 1
		sel_idx = tot_idx 

	elif mdl_type == 'EDvTC':
		sel_idx = tot_idx[nzidx]
		Ytrain = Ytrain[sel_idx]

		ed_idx = Ytrain == 2
		Ytrain[ed_idx] = 0
		tc_idx = Ytrain != 0
		Ytrain[tc_idx] = 1

	elif mdl_type == 'ENvNE':
		ned_idx = Ytrain !=2
		TC_idx = np.logical_and(nzidx,ned_idx)
		sel_idx = tot_idx[TC_idx]
		Ytrain = Ytrain[sel_idx]

		en_idx = Ytrain == 4
		Ytrain[en_idx] = 0
		ne_idx = Ytrain != 0
		Ytrain[ne_idx] = 1
		
	else:
		print('Model type not recognized')

	return Ytrain,sel_idx

def SetData(Xtrain,Ytrain,mdl_type):
	Ytrain,sel_idx = SetLabels(Ytrain,mdl_type)
	Xtrain = Xtrain[sel_idx]
	return Xtrain,Ytrain

def TrainClassifierWithVal(Xtrain,Ytrain,params,mdl_type,iters,Xtest,Ytest):
	nn = Xtrain.shape[0]
	dd = Xtrain.shape[1]

	# modelfile
	model_dir = os.environ['BRATSDIR'] + '/classification/training/models/';	
	mdlfile = model_dir + mdl_type + '.lgbm.renorm.i'+str(iters)+'.txt'
	print('Saving to ' + mdlfile)

	# Make lgbm datasets
	lgb_train = lgb.Dataset(Xtrain,label=Ytrain,max_bin=1023)
	lgb_val = lgb.Dataset(Xtest,Ytest,reference=lgb_train)
	
	# Train full model
	print(' train model ')
	start = time.time()
	lgb_model = lgb.train(params,lgb_train,valid_sets=[lgb_val],verbose_eval=10,num_boost_round=iters)
	end = time.time()
	print(' Model took ' +  str(end-start) ) 

	# nt 
	nt = Xtest.shape[0];
	
	# Run on testing data 
	start = time.time()
	Ypred = lgb_model.predict(Xtest) 
	Ypo = Ypred
	Ypred = Ypred.round()
	end = time.time()
	print(' Predict took ' +  str(end-start) ) 
	corr_count = 0
	for ii in range(nt):
		if Ypred[ii] == Ytest[ii]:
			corr_count += 1
	
	print('Test accuracy: ' + str(corr_count/float(nt) ))
	print(confusion_matrix(Ytest,Ypred))
	
	# save model
	lgb_model.save_model(mdlfile)

def TrainClassifier(Xtrain,Ytrain,params,mdl_type,iters):
	# modelfile
	model_dir = os.environ['BRATSDIR'] + '/classification/training/models/';	
	#model_dir = os.environ['BRATSDIR'] + '/userbrats/BRATS17shashank/';	
	

	nn = Xtrain.shape[0]
	dd = Xtrain.shape[1]
	mdlfile = model_dir + mdl_type + '.lgbm.nn.' + str(nn) + '.dd.' + str(dd) + '.txt'
	mdlfile = model_dir + mdl_type + '.lgbm.renorm.'+str(iters)+'.txt'
	print('Saving to ' + mdlfile)
	
	
	# Training lgbm dataset 
	lgb_train = lgb.Dataset(Xtrain,label=Ytrain,max_bin=1023)
	
	# Train full model
	print(' train model ')
	start = time.time()
	lgb_model = lgb.train(params,lgb_train,num_boost_round=iters)
	end = time.time()
	print(' Model took ' +  str(end-start) ) 
	
	# save model
	lgb_model.save_model(mdlfile)


# actually run everything
#print('Running NO v WT')
#main('NOvWT')

#print('Running EDvTC')
#main('EDvTC')

print('Running ENvNE')
main('ENvNE')
