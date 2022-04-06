# OCI-based Upgrade Lab
Lab resources for practicing Oracle database upgrades from 11g/12c to 21c using Oracle Cloud Infrastructure resources.

Older versions of Oracle (pre-12.2) do not enjoy a direct path upgrade to 21c. Instead, users must first upgrade the older database to an intermediate version, then migrate that database to 21c. At some point, the older, non-Container Database (non-CDB) must be converted to a Pluggable Database (PDB). In this lab, that's performed in the final, non-CDB to PDB migration step.

This lab uses Docker images and prepared snapshots, allowing students to quickly refresh the lab to any point. It runs on Oracle Cloud Infrastructure but does *not* use Always-Free resources. However, it will run on an Oracle Free Tier account using credits during the introductory period. Cost for running the lab is approximately $2.50/day for block storage and $3-5/day for compute resources. Compute doesn't incur charges if the instance is stopped. It is possible to run this on Always Free resources but the performance and experience are poor. Setup takes a very long time due to bandwidth limits on Always Free compute; rebuilding the lab is time-consuming; the upgrade process is slow; and we have to "trick" Oracle to get it to run two databases (source, target) on a machine with 1GB RAM.

## Deploy on OCI
To deploy this lab on Oracle Cloud Infrastructure, [create a new Always Free Tier account](https://signup.cloud.oracle.com), log in to an existing Free Tier account during the trial period, or log into a paid account.

Then, click on the "Deploy to Oracle Cloud" button:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oraclesean/upgrade-lab/archive/refs/tags/v1.04.zip)

Accept the Oracle Terms of Use and click the "Next" button.

![p1](/images/p1.png)

Confirm that you have accepted the License Agreement by checking the box.

![p2](/images/p2.png)

Add or paste an SSH key.  [How to generate an SSH key](https://docs.oracle.com/en/cloud/cloud-at-customer/occ-get-started/generate-ssh-key-pair.html)

![p3](/images/p3.png)

Select the source database version, either 11 (for 11.2.0.4) or 12 (for 12.1.0.2).

![p4](/images/p4.png)

Check "Show advanced options" if you want to assign the lab to a specific compartment, change the instance shape (the default is VM.Standard.E3.Flex), or increase OCPU or memory.

![p4](/images/p5.png)

Click the "Next" button.

![p6](/images/p6.png)

Review the stack information and make sure the "Run Apply" checkbox is checked, then click the "Create" button.

![p7](/images/p7.png)

Resource Manager will begin building the stack. The Resource Manager Job icon turns green when it finishes the initial provisioning.

![p8](/images/p8.png)

A new tab will appear (you may need to reload the page) titled "Application Information". Select this tab.

![p9](/images/p9.png)

Copy the "Compute public IP address" using the 'Copy' option.

![p10](/images/p10.png)

Open a terminal or shell session on your local machine and enter the following command, substituting the path to your SSH key and the public IP address of the compute instance you just copied from OCI:

```
ssh -l opc -i <path to your key> <compute public IP address>
```

Full provisioning takes roughly 33 minutes. The instance is ready when the last line of  `/tmp/setup-docker.log` reads `Docker and database setup is complete`.
