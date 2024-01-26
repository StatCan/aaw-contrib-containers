from office365.runtime.auth.client_credential import ClientCredential
from office365.sharepoint.client_context import ClientContext
from office365.sharepoint.files.file import File
import io
import pandas as pd

class SharepointUtils:    

    # creates the sharepoint connection
    def __init__(self, client_id, client_secret, site_url, file_url, sheet_name, list_title, list_column, list_max_return):

        client_creds = ClientCredential(client_id, client_secret)
        self.ctx = ClientContext(site_url).with_credentials(client_creds)
        self.file_url = file_url
        self.sheet_name = sheet_name
        self.list_title = list_title
        self.list_column = list_column
        self.list_max_return = list_max_return


    def get_intake_form_data_as_dataframe(self):

        # connect to sharepoint and get the xslx file
        response = File.open_binary(self.ctx, self.file_url)

        # save data to BytesIO stream
        bytes_file_obj = io.BytesIO()
        bytes_file_obj.write(response.content)
        bytes_file_obj.seek(0) #set file object to start

        # read excel file and each sheet into pandas dataframe 
        df = pd.read_excel(bytes_file_obj, self.sheet_name)
        # drop empty rows. inplace=True modifies the existing dataframe instead of returning a new one.
        df.dropna(inplace=True, subset=['ID'])
        # remove the already processed ids from the dataframe
        processed_ids = self.get_processed_id_list()
        df = df[df.ID.isin(processed_ids) == False]

        return df

    def get_processed_id_list(self):

        # connect to sharepoint and get the list of IDs
        raw_list = self.ctx.web.lists.get_by_title(self.list_title)
        id_list = raw_list.items.get().select([self.list_column]).top(self.list_max_return).execute_query()

        print("Total number of processed applications before this run: {0}".format(len(id_list)))
        processed_id_list = []

        for index, item in enumerate(id_list):  # type: int, ListItem
            application_id = float(item.properties[self.list_column]) #convert to float to match dataframe
            processed_id_list.append(application_id)
        
        return processed_id_list

    def add_processed_id_to_list(self, new_id):
        
        raw_list = self.ctx.web.lists.get_by_title(self.list_title)
        new_list_item_properties = {
            self.list_column: str(new_id) #need to convert back to string because sharepoint wants it that way
        }
        new_item = raw_list.add_item(new_list_item_properties).execute_query()
        return new_item
