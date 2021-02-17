This document lists the configuration options for your CxFlow yml file when integrating with CxSCA.

* For an introduction to CxFlow, follow the [CxFlow Guide](https://github.com/checkmarx-ltd/cx-flow/wiki).
* For a more general set of config options, see [CxFlow Configuration Options](https://github.com/checkmarx-ltd/cx-flow/wiki/Configuration).
* To view a large example CxFlow .yml file, please refer to the [Example File](https://github.com/checkmarx-ltd/cx-flow/wiki/YML-Example-Files).

## Enable CxSCA
To enable CxSCA, "sca" has to be added as a value to the "enabled-vulnerability-scanners" key within the "cx-flow" map.  You can choose to trigger one or more scanners. The example below has been set to trigger both CxSCA and CxSAST.
```
cx-flow:
    enabled-vulnerability-scanners:
        - sca
        - sast
```

In addition, add a "sca" map with at least the required following keywords and values:
```
sca:
    appUrl: https://sca.scacheckmarx.com
    apiUrl: https://api.scacheckmarx.com
    accessControlUrl: https://platform.checkmarx.net
    tenant: <your-tenant-name>
    username: <user>
    password: <password>
```

## SCA Keywords
Keyword | Description
------------ | ------------	
appUrl | URL of CxSCA Server.  Currently always: "https://sca.scacheckmarx.com"
apiUrl | URL of CxSCA API Endpoint.  Currently always: "https://api.scacheckmarx.com"
accessControlUrl | URL of Access Control.  Currently always: https://platform.checkmarx.net
tenant | Name of CxSCA Tenant
username | Username of CxSCA Server
password | Password of CxSCA Server
[filter-severity](#filter-severity) | List type and can have multiple values [High, Medium, Low]
[filter-score](#filter-score) | Double value starting from ‘0.0’
[thresholds-severity](#thresholds) | The maximum number of findings (per severity) allowed, before failing the pull request.
[thresholds-score](#thresholds) | The maximum acceptable score (of all findings), before failing the pull request.
[enabledZipScan](#zipFolderScan) | True/False.  Set to true to change the default CxFlow CxSCA scan behavior and to perform a zip scan.
includeSources | True/False.  Set to true to change the default CxFlow CxSCA scan behavior to upload the source files.
[team-for-new-projects](#scaProjectTeamAssignment) | Set a project team (i.e. '/TeamAlpha')



* [SCA Policy Management](#policyManagement)
* [SCA Configuration As Code](#configurationascode)
* [SCA Scans From Command Line](#commandline)

## <a name="configuration">Configuration</a>


## <a name="filter-serverity">Filter on Severity</a>
CxSCA filtering has 2 sections: filter-severity & filter-score:
* Filter Severity: is a list type and can have multiple values [high, medium, low] regardless the order and not case sensitive. When applying this filter the CxSCA results vulnerabilities will be sanitized according to the severities defined filter.
  * Special cases:
    * Filter not defined: in that case the severity filter won’t be applied and the returned results will contain all scan severities.
    * Unrecognized filter defined: in that case this filter value will be ignored.

## <a name="filter-score">Filter on Score</a>
* Filter Score: is a double value starting from ‘0.0’.
  * Special cases:
    * Negative value will be ignored.
    * Filter not defined: in that case the score severity won’t be applied and the returned results will contain all scan scores.
* Combined filters: In case both severity & score filter were defined, the returned results will contain only vulnerabilities which apply both conditions.
  * Backwards Compatibility: in case none of the filters were defined, the returned results won’t be sanitized and all scan’s results will be returned

## <a name="thresholds">Thresholds</a>
CxFlow supports 2 kind of thresholds: 
* Severity  Thresholds (count per severity): 
* Score Threshold 
<br/>When performing a scan, if at least one of the thresholds is violated, Cx-Flow will fail the pull request and it will be marked as failed. 

### Feature SCM Supportability 
The thresholds feature is supported in the following source-code managements: 
* ADO 
* GitHub 
* BitBucket  

### Configuration changes required – via application.yml 
Thresholds are configured in the application.yml within the sca section:
<br/>
[[/Images/SCA6.png|Severity and Score Threshold examples]]

### On the supported SCM sections: (e.g. GitHub section) 
* Define the block-merge with true value 
* Define the error-merge with true value 

### Threshold configuration – General 
CxFlow uses the thresholds to ease its (no) tolerance of findings.  
* Severity – this threshold tells CxFlow what is the maximum number of findings (per severity) allowed, before failing the pull request. 
* Score – this threshold tells CxFlow what is the maximum acceptable score (of all findings), before failing the pull request. 
<br/>Note:  
* if only one threshold type is defined, the other one will be ignored 
* that the thresholds are on findings and not on issues. 
* if no threshold is defined, CxFlow will fail the pull request if there is any finding. 
* thresholds are checked after the execution of filters. 
<br/>An example for pull request failure: 
<br/>
[[/Images/SCA7.png|Example of Pull Request Failure]]

## <a name="policyManagement">Policy Management</a>
CxSCA supports with policy management control.
Each policy can be customized by defining number of custom rules and conditions in which, if getting violated, can break a build.
On the creation process or after it, a policy can be defined with 'Break build' flag or not.

[[/Images/SCA-policy-creation.png|Example of Policy creation dashboard]]

When performing a scan, if a defined policy is getting violated, CxFlow will fail the pull request and it will be marked as failed.
* Violated policy occurs when at least one rule condition is getting violated AND when policy 'Break Build' flag in on.
* In case of a CLI scan which violated a policy: CxFlow will fail with exit code 10.
* If current scan violated any active CxSCA thresholds and also violated a policy, policy break build has the top priority.


## <a name="configurationascode">Configuration As Code</a>
CxFlow supports configuration as code for CxSAST and CxSCA scans.
<br/>Available overrides for CxSCA properties:
* additionalProperties:
  * vulnerabilityScanners
* sca:
  * appUrl
  * apiUrl
  * accessControlUrl
  * tenant
  * thresholdsSeverity
  * thresholdsScore
  * filterSeverity
  * filterScore
<br/>Example for CxSCA config file content:
```
{
    "additionalProperties": {
        "cxFlow": {
			"vulnerabilityScanners": ["sca", "sast"]
        }
    },
	"sca": {
		"appUrl": "sampleAppUrl",
		"apiUrl": "sampleApiUrl",
		"accessControlUrl": "sampleAccessControlUrl",
		"tenant": "sampleTenant",
		"thresholdsSeverity": {
			"HIGH": 10,
			"MEDIUM": 6,
			"LOW": 3
		},
		"thresholdsScore": 8.5,
		"filterSeverity": ["high", "medium", "low"],
		"filterScore": 7.5
	}
}
```

## <a name="commandline">CxSCA Scans From Command Line</a>
### CxFlow can initiate CxSCA scans with command line mode
<br/>There are 2 options to add SCA scan to the cli run:
* Add scanner argument to the cli command:  --scanner=sca 
* Add sca to the active vulnerabilities scanner in cxflow app.yml: 
[[/Images/SCA8.png|Example of enables-vulnerbaility-scanners]]
 
### CxFlow can init git scan or upload zip folder to scan by sca:
* git scan:
  * -scan  --enabled-vulnerability-scanners=sca --app=MyApp --cx-project=test --repo-url=my-repo-url --repo-name=my-repo --branch=master --github  
* local zip scan:
  * -scan --app=MyApp --cx-team="my-team" --cx-project="project" --f="/Users/myProjects/project"
* get latest scan results:
  * --project --app=MyApp --cx-team="my-team" --cx-project="project" ([use 'project' command](https://github.com/checkmarx-ltd/cx-flow/blob/develop/src/main/java/com/checkmarx/flow/dto/ScanRequest.java))


## <a name="zipFolderScan">CxSCA zip folder scan</a>
In order to change the default CxFlow CxSCA scan behaviour and to perform a CxSCA zip scan, the following configuration property should be added within the "sca" configuration section:
```
enabledZipScan: true
```
Additional configuration in CxSCA zip scan flow - Include source files
* Default value set to false, In order to change the default CxFlow CxSCA zip scan behaviour, the next configuration property should be added underneath the sca configuration section:
```
includeSources: true
```

## <a name="scaProjectTeamAssignment">CxSCA Project Team Assignment</a>
CxSCA project team assignment with CxFlow is performed at the CxSCA project creation stage. In order to set a project team, the following configuration property should be added within the "sca" configuration section:
```
team-for-new-projects: '/team'
```
Or within a tree hierarchy:
```
team-for-new-projects: '/MainTeam/SubTeam'
```
* In order to declare a team within a tree hierarchy, make sure to use the forward slash ('/').
* Declaring a team or team path that doesn't exist will result with a 400 BAD REQUEST error.
