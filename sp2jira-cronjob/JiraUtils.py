from jira import JIRA

class JiraUtils:

    # parameterized constructor
    def __init__(self, jira_server, jira_auth_token, jira_project, jira_issue_type, jira_assignee, jira_watchers):
        
        self.jira = JIRA(server=jira_server, token_auth=jira_auth_token)
        self.jira_project = jira_project
        self.jira_issue_type = jira_issue_type
        self.jira_assignee = jira_assignee
        self.jira_watchers = jira_watchers

    def create_jira_issue_from_form_data(self, issue_summary, issue_desc):
        
        issue_dict = {
            'project': {'key': self.jira_project},
            'summary': issue_summary,
            # epic name field
            'customfield_10704': issue_summary,
            'description': issue_desc,
            'issuetype': {'name': self.jira_issue_type},
            'assignee': {'name': self.jira_assignee}
        }

        new_issue = self.jira.create_issue(fields=issue_dict)
        # this can't be done as part of issue creation, unfortunately
        for watcher in self.jira_watchers:
            self.jira.add_watcher(new_issue, watcher)

        return new_issue
