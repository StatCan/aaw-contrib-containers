import os
import json
import pandas as pd
from JiraUtils import JiraUtils
from SharepointUtils import SharepointUtils

# initialize JIRA variables and helper class. see README for details.
# mandatories
jira_server = os.environ["JIRA_SERVER"] #"https://jirab.statcan.ca"
jira_auth_token = os.environ["JIRA_TOKEN"]
jira_project = os.environ["JIRA_PROJECT"] #"DASBOP"
jira_assignee = os.environ["JIRA_ASSIGNEE"] #"luodan"
jira_watchers = json.loads(os.environ['JIRA_WATCHERS']) #["zimmshe", "bonedan", "coutann"] https://stackoverflow.com/questions/31352317/how-to-pass-a-list-as-an-environment-variable 
#optionals
jira_issue_type = os.environ.get('JIRA_ISSUE_TYPE', "Epic")
jira_issue_summary = os.environ.get('JIRA_ISSUE_SUMMARY', "DAS Intake Form submission by {0} {1}")
jira_desc_no_response = os.environ.get('JIRA_ISSUE_DESC_NO_RESPONSE', "No Response")

jira = JiraUtils(jira_server, jira_auth_token, jira_project, jira_issue_type, jira_assignee, jira_watchers)

# initialize sharepoint variables and helper class. see README for details.
#mandatories
client_id = os.environ['SHAREPOINT_CLIENT_ID']
client_secret = os.environ['SHAREPOINT_CLIENT_SECRET']
site_url = os.environ['SHAREPOINT_SITE_URL'] #"https://054gc.sharepoint.com/sites/DAaaSD-AllStaff-DADS-Touslesemployes"
file_url = os.environ['SHAREPOINT_FILE_URL'] #"/sites/DAaaSD-AllStaff-DADS-Touslesemployes/Shared%20Documents/CSU%20-%20UCS/DAaaS%20Intake%20Form/Data%20Analytics%20Services%20(DAS)%20-%20Get%20started%201.xlsx"
list_title = os.environ['SHAREPOINT_LIST_TITLE'] #"Intake_form_processed_ids"
#optionals
sheet_name = os.environ.get('SHAREPOINT_SHEET_NAME', "Form1")
ID_COL = os.environ.get('SHAREPOINT_ID_COLUMN', 0)
FNAME_COL = os.environ.get('SHAREPOINT_FNAME_COLUMN', "First name")
LNAME_COL = os.environ.get('SHAREPOINT_LNAME_COLUMN', "Last name")
list_column = os.environ.get('SHAREPOINT_LIST_COLUMN', "Title" )
list_max_return = os.environ.get('SHAREPOINT_LIST_MAX_RETURN', 5000) #if we ever get more applications than this we'll have to adjust it

sputils = SharepointUtils(client_id, client_secret, site_url, file_url, sheet_name, list_title, list_column, list_max_return)


# get the form data from sharepoint
df = sputils.get_intake_form_data_as_dataframe()

## go through each row and create a JIRA issue, saving processed IDs to the sharepoint list so we don't create them again later
issue_count = 0
for index, row in df.iterrows():

    current_id = row[ID_COL]
    issue_desc = ""
    issue_summary = jira_issue_summary.format(row[FNAME_COL], row[LNAME_COL])
    
    for rowindex, rowval in row.items():
        issue_desc += f"{rowindex} : \n"
        if pd.isna(rowval):
            issue_desc += f"*{jira_desc_no_response}*\n\n"
        else:
            issue_desc += f"*{rowval}*\n\n"

    print(f"JIRA issue to be created from row id: {current_id}")
    print(f"Summary: {issue_summary}")
    #print(issue_desc) #left for debug

    try:
        new_issue = jira.create_jira_issue_from_form_data(issue_summary, issue_desc)
    except:
        print(f"Error creating JIRA issue from ID {current_id}")
    else:
        sputils.add_processed_id_to_list(current_id)
        issue_count += 1
        print(new_issue)

print(f"Process completed. {issue_count} issues created.")
