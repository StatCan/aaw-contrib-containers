# sp2jira-cron-container
- intended to be run as a k8s cronjob.
- retrieves ms forms submissions from a sharepoint excel file, and creates a jira issue 
- keeps track of already-processed submissions via a Sharepoint List

# TODO
- set up dev form / excel, dev list, dev jira project, test running both prod and dev with same container
- dockerfile / compose.yaml currently set up with defaults for a service, need to research what to change here for a cronjob but it's working

## environment variables
The following environment variables are used by the script.

### Jira
| Variable | Mandatory | Description |
| ----------- | ----------- | ----------- |
| `JIRA_SERVER` | * | URL of the jira server. e.g. https://jirab.statcan.ca |
| `JIRA_TOKEN` | * | the token used to authorize the script with the jira server |
| `JIRA_PROJECT` | * | the Jira project that tickets will be created in |
| `JIRA_ASSIGNEE` | * | the Jira user that Jira issues will be assigned to |
| `JIRA_WATCHERS` | * | json list of Jira users that will be added to new Jira issues as watchers. See https://stackoverflow.com/questions/31352317/how-to-pass-a-list-as-an-environment-variable |
| `JIRA_ISSUE_TYPE`| | the Jira project that tickets will be created in. Default is 'Epic' |
| `JIRA_ISSUE_SUMMARY`| | text for the issue summary. Defaults to 'DAS Intake Form submission by {0} {1}', where 0 is FNAME and 1 is LNAME |
| `JIRA_ISSUE_DESC_NO_RESPONSE`| | what to put when an answer hasn't been provided in a submission. Default is 'No Response' |

### Sharepoint
| Variable | Mandatory | Description |
| ----------- | ----------- | ----------- |
| `SHAREPOINT_CLIENT_ID` | * | the id used to authorize the script with the sharepoint site |
| `SHAREPOINT_CLIENT_SECRET` | * | the secret used to authorize the script with the sharepoint site |
| `SHAREPOINT_SITE_URL` | * | URL of the sharepoint site |
| `SHAREPOINT_FILE_URL` | * | Path to the .xslx file in sharepoint. |
| `SHAREPOINT_LIST_TITLE`| * | Name of the processed id list in sharepoint. |
| `SHAREPOINT_SHEET_NAME` |  | Name of the excel sheet used. Default is 'Form1' |
| `SHAREPOINT_ID_COLUMN` |  | Name of the excel sheet used. Default is '0' |
| `SHAREPOINT_FNAME_COLUMN` |  | Name of the column containing First Name. Default is 'First name' |
| `SHAREPOINT_LNAME_COLUMN` |  | Name of the column containing Last Name. Default is 'Last name' |
| `SHAREPOINT_LIST_COLUMN`|  | Name of the list column in sharepoint containing processed ID data. Default is 'Title' |
| `SHAREPOINT_LIST_MAX_RETURN`|  | Maximum number of list items to fetch. Default is '5000' |

