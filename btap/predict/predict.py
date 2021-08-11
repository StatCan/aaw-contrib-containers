import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.keras import layers
import tensorflow_docs as tfdocs
import tensorflow_docs.plots
import tensorflow_docs.modeling
from keras import backend as K
from keras.models import Sequential
from keras.utils import np_utils
from keras.layers import Dense, Dropout, GaussianNoise, Conv1D,Flatten
from keras import regularizers      #for l2 regularization
from keras.wrappers.scikit_learn import KerasRegressor
from sklearn.compose import TransformedTargetRegressor
from sklearn.pipeline import Pipeline
from sklearn import metrics




############################################################    
# Predict energy consumed
############################################################
def create_model(func_name):
    """
    Select the function to use
    """
    if func_name == "large":
        model = Sequential()
        model.add(Dense(13, input_dim=3, kernel_initializer='normal', activation='relu'))
        model.add(Dense(6, kernel_initializer='normal', activation='relu'))
        model.add(Dense(1, kernel_initializer='normal'))
        # Compile model
        model.compile(loss='mean_squared_error', optimizer='adam')
        return model
    elif func_name == "wide":
        # create model
        model = Sequential()
        model.add(Dense(20, input_dim=3, kernel_initializer='normal', activation='relu'))
        model.add(Dense(1, kernel_initializer='normal'))
        # Compile model
        model.compile(loss='mean_squared_error', optimizer='adam')
        return model
    elif func_name == "deep":
        model = Sequential()
        model.add(Dense(16, input_dim=2, kernel_initializer='normal', activation='relu'))
        model.add(Dense(10, kernel_initializer='normal', activation='relu'))
        model.add(Dense(1, kernel_initializer='normal'))
        # Compile model
        model.compile(loss='mean_squared_error', optimizer='adam')
        return model
    else:
        return func_name+ " not valid"



def predicts(X_train,y_train,n_splits=10, model='mlp',func_name,Epochs=50,Batch_size=5, verbose=0,Scaler='standardize',selected_feature): 
    model = create_model(func_name)
    estimators = []
    estimators.append((Scaler, StandardScaler()))
    estimators.append((model, KerasRegressor(build_fn=Build_fn, epochs=Epochs, batch_size=Batch_size, verbose=verbose)))
    pipeline = Pipeline(estimators)

    # prepare the model with target scaling
    model = TransformedTargetRegressor(regressor=pipeline, transformer=StandardScaler())
    # evaluate model
    kfold = KFold(n_splits=n_splits)
    results = cross_val_predict(model, X_train[selected_feature].values, y_train, cv=kfold)
        
    return results
    
    
def score(y_test,val_predict): 
    
    r2_scores=metrics.r2_score(y_test,val_predict)
    mse = metrics.mean_squared_error(y_test,val_predict)
    mae = metrics.mean_absolute_error(y_test,val_predict)
    mape = metrics.mean_absolute_percentage_error(y_test,val_predict)
    rmse = sqrt(mse)
        
    scores = {"mape":mape,
              "r2_scores": r2_scores,
              "rmse": rmse,
              "mae":mae}
    return scores


#def fit_evaluate(X_train, X_test,y_train,y_test, selected_feature,func_name):  
def fit_evaluate(args): 
     # Open and reads file "data"
    with open(args.input_path) as data_file:
        data = json.load(data_file)
    
    X_test = data["X_test"]
    X_train = data["X_train"]
    y_test = data["y_test"]
    y_train = data["y_train"]
    Build_fn = create_model(args.model)
    
    results_test = predicts(X_test[args.features].values, y_test,Build_fn)  
    results_train = predicts(X_train[args.features].values, y_train,Build_fn)  
        
    scores_test  = score(df_results_test, df_train) 
    scores_train  = score(df_results_train, df_train)
    
    result= {'scores_test' : scores_test.tolist(),
            'scores_train' : scores_train.tolist(),
            'results_train' : results_train.tolist(),
            'results_test' : results_test.tolist()}
    return result


if __name__ == '__main__':
    
    # This component does not receive any input it only outpus one artifact which is `data`.
    # Defining and parsing the command-line arguments
    parser = argparse.ArgumentParser()
    
     # Paths must be passed in, not hardcoded
    parser.add_argument('--input_path', type=str, help='Name of data file to be read')
    parser.add_argument('--features', type=str, help='selected features')
    parser.add_argument('--model', type=str, help='the type of MLP moodel to run')
    parser.add_argument('--output_path', type=str, help='Path of the local file where the output file should be written.')
    args = parser.parse_args()
    
    Path(args.output_path).parent.mkdir(parents=True, exist_ok=True)
    fit_evaluate(args)
    import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.keras import layers
import tensorflow_docs as tfdocs
import tensorflow_docs.plots
import tensorflow_docs.modeling
from keras import backend as K
from keras.models import Sequential
from keras.utils import np_utils
from keras.layers import Dense, Dropout, GaussianNoise, Conv1D,Flatten
from keras import regularizers      #for l2 regularization
from keras.wrappers.scikit_learn import KerasRegressor
from sklearn.compose import TransformedTargetRegressor
from sklearn.pipeline import Pipeline
from sklearn import metrics




############################################################    
# Predict energy consumed
############################################################
def create_model(func_name):
    """
    Select the function to use
    """
    if func_name == "large":
        model = Sequential()
        model.add(Dense(13, input_dim=3, kernel_initializer='normal', activation='relu'))
        model.add(Dense(6, kernel_initializer='normal', activation='relu'))
        model.add(Dense(1, kernel_initializer='normal'))
        # Compile model
        model.compile(loss='mean_squared_error', optimizer='adam')
        return model
    elif func_name == "wide":
        # create model
        model = Sequential()
        model.add(Dense(20, input_dim=3, kernel_initializer='normal', activation='relu'))
        model.add(Dense(1, kernel_initializer='normal'))
        # Compile model
        model.compile(loss='mean_squared_error', optimizer='adam')
        return model
    elif func_name == "deep":
        model = Sequential()
        model.add(Dense(16, input_dim=2, kernel_initializer='normal', activation='relu'))
        model.add(Dense(10, kernel_initializer='normal', activation='relu'))
        model.add(Dense(1, kernel_initializer='normal'))
        # Compile model
        model.compile(loss='mean_squared_error', optimizer='adam')
        return model
    else:
        return func_name+ " not valid"



def predicts(X_train,y_train,n_splits=10, model='mlp',func_name,Epochs=50,Batch_size=5, verbose=0,Scaler='standardize',selected_feature): 
    model = create_model(func_name)
    estimators = []
    estimators.append((Scaler, StandardScaler()))
    estimators.append((model, KerasRegressor(build_fn=Build_fn, epochs=Epochs, batch_size=Batch_size, verbose=verbose)))
    pipeline = Pipeline(estimators)

    # prepare the model with target scaling
    model = TransformedTargetRegressor(regressor=pipeline, transformer=StandardScaler())
    # evaluate model
    kfold = KFold(n_splits=n_splits)
    results = cross_val_predict(model, X_train[selected_feature].values, y_train, cv=kfold)
        
    return results
    
    
def score(y_test,val_predict): 
    
    r2_scores=metrics.r2_score(y_test,val_predict)
    mse = metrics.mean_squared_error(y_test,val_predict)
    mae = metrics.mean_absolute_error(y_test,val_predict)
    mape = metrics.mean_absolute_percentage_error(y_test,val_predict)
    rmse = sqrt(mse)
        
    scores = {"mape":mape,
              "r2_scores": r2_scores,
              "rmse": rmse,
              "mae":mae}
    return scores


#def fit_evaluate(X_train, X_test,y_train,y_test, selected_feature,func_name):  
def fit_evaluate(args): 
     # Open and reads file "data"
    with open(args.input_path) as data_file:
        data = json.load(data_file)
    
    X_test = data["X_test"]
    X_train = data["X_train"]
    y_test = data["y_test"]
    y_train = data["y_train"]
    Build_fn = create_model(args.model)
    
    results_test = predicts(X_test[args.features].values, y_test,Build_fn)  
    results_train = predicts(X_train[args.features].values, y_train,Build_fn)  
        
    scores_test  = score(df_results_test, df_train) 
    scores_train  = score(df_results_train, df_train)
    
    result= {'scores_test' : scores_test.tolist(),
            'scores_train' : scores_train.tolist(),
            'results_train' : results_train.tolist(),
            'results_test' : results_test.tolist()}
    return result


if __name__ == '__main__':
    
    # This component does not receive any input it only outpus one artifact which is `data`.
    # Defining and parsing the command-line arguments
    parser = argparse.ArgumentParser()
    
     # Paths must be passed in, not hardcoded
    parser.add_argument('--input_path', type=str, help='Name of data file to be read')
    parser.add_argument('--features', type=str, help='selected features')
    parser.add_argument('--model', type=str, help='the type of MLP moodel to run')
    parser.add_argument('--output_path', type=str, help='Path of the local file where the output file should be written.')
    args = parser.parse_args()
    
    Path(args.output_path).parent.mkdir(parents=True, exist_ok=True)
    fit_evaluate(args)
    
