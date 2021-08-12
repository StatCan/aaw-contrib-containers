from sklearn.feature_selection import RFECV 
from sklearn.linear_model import LinearRegression, LassoCV
from sklearn.ensemble import RandomForestRegressor
import json

############################################################    
# feature selection
############################################################

#def select_features(X_train,y_train, features, estimator_type ='linear',min_features=1 ):
def select_features(args,estimator_type ='linear',min_features=1): 
    """
    Select the feature which contribute most to the prediction for the total energy consumed.  
    """
     # Open and reads file "data"
    with open(args.input_path) as data_file:
        data = json.load(data_file)
        
    if estimator_type == "linear":
        estimator = LinearRegression()
        rfecv = RFECV(estimator=estimator, step=1, cv=KFold(10),scoring='neg_mean_squared_error',min_features_to_select=min_features_to_select)
        fit = rfecv.fit(data["X_train"],data["y_train"])
        rank_features_nun = pd.DataFrame(rfecv.ranking_, columns=["rank"], index = data["X_train"].columns)
        selected_features = rank_features_nun.loc[rank_features_nun["rank"]==1].index.tolist() 
        return selected_features
    elif estimator_type == "rf":
#         estimator = RandomForestRegressor(**params, n_jobs = -1)
        estimator = RandomForestRegressor(n_jobs = -1)
        rfecv = RFECV(estimator=estimator, step=1, cv=KFold(10),scoring='neg_mean_squared_error', min_features_to_select=min_features_to_select)
        fit = rfecv.fit(data["X_train"],data["y_train"])
        rank_features_nun = pd.DataFrame(rfecv.ranking_, columns=["rank"], index = data["X_train"].columns)
        selected_features = rank_features_nun.loc[rank_features_nun["rank"]==1].index.tolist() 
        return selected_features
    elif estimator_type == "elasticnet":
#         tscv = TimeSeriesSplit(n_splits = 2, gap=0, test_size=12)
#         estimator = ElasticNetCV(**params, n_alphas=10, cv=tscv, max_iter = 1000, n_jobs=-1)
        estimator = ElasticNet(**params)
        rfecv = RFECV(estimator=estimator, step=1, cv=KFold(10),scoring='neg_mean_squared_error', min_features_to_select=min_features_to_select)
        fit = rfecv.fit(data["X_train"],data["y_train"])
        rank_features_nun = pd.DataFrame(rfecv.ranking_, columns=["rank"], index = data["X_train"].columns)
        selected_features = rank_features_nun.loc[rank_features_nun["rank"]==1].index.tolist() 
        return selected_features        
    elif estimator_type == "xgb":
        estimator = xgb.XGBRegressor(n_jobs = multiprocessing.cpu_count())
        #estimator = xgb.XGBRegressor(**params, n_jobs = multiprocessing.cpu_count())        
        rfecv = RFECV(estimator=estimator, step=1, cv=KFold(10),scoring='neg_mean_squared_error', min_features_to_select=min_features_to_select)
        fit = rfecv.fit(data["X_train"],data["y_train"])
        rank_features_nun = pd.DataFrame(rfecv.ranking_, columns=["rank"], index = data["X_train"].columns)
        selected_features = rank_features_nun.loc[rank_features_nun["rank"]==1].index.tolist() 
        return selected_features
    elif estimator_type == "lasso":
        reg = linear_model.LassoCV(cv=10, random_state=0)
        fit = reg.fit(data["X_train"],data["y_train"])
        rank_features_nun = pd.DataFrame(reg.coef_, columns=["rank"], index = data["X_train"].columns)
        selected_features = rank_features_nun.loc[abs(rank_features_nun["rank"])>0].index.tolist()  
        return selected_features
    else:
        return features


if __name__ == '__main__':
    
    # This component does not receive any input it only outpus one artifact which is `data`.
    # Defining and parsing the command-line arguments
    parser = argparse.ArgumentParser()
    
     # Paths must be passed in, not hardcoded
    parser.add_argument('--input_path', type=str, help='Name of data file to be read')
    parser.add_argument('--output_path', type=str, help='Path of the local file where the output file should be written.')
    args = parser.parse_args()
    
    Path(args.output_path).parent.mkdir(parents=True, exist_ok=True)
    select_features(args)
    
