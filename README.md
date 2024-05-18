# Apache Stanbol Container
This is an attempt to containerize the Apache Stanbol and adjust it to the ACDH-CH k8s environment.
Apache Stanbol (enrich) is a modular set of components and HTTP services for semantic content management.

|Name|Required|Type|Level|Description|
|----|:------:|----|:---:|-----------|
|KUBE_NAMESPACE|:white_check_mark:|Variable|Repo/Env|The K8s namespace the deployment should be installed to. |
|SERVICE_ID|:white_check_mark:|Variable|Env|A K8s label ID is attached to the workload/deployment with this value (usually a number) |
|PUBLIC_URL|:white_check_mark:|Variable|Env|The URI with https:// that should be configured for access to the service. |
|C2_KUBE_INGRESS_BASE_DOMAIN|:white_check_mark:|Variable|Org/Repo/Env|If you deploy using the workflow for the second cluster the C2_ variant is used |
|HELM_UPGRADE_EXTRA_ARGS||Variable|Repo/Env|Used to set a few values from the Helm charts value.yaml using `--set` command line parameters to `helm`. If you have to set more or nested values better use a `auto-deploy-values.yaml` file in the git repository. Store as a Secret if you `--set` sensitive information (not recommended) |

NOTE:
After deployment update role manager-gui by adding credentials for it to /usr/local/tomcat/conf/tomcat-users.xml and edit context for manager/host-manager.


Following PVC are required:
* usr-local-tomcat-logs
* usr-local-tomcat-stanbol
* usr-local-tomcat-webapps
