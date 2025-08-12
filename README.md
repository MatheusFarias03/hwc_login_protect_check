# HWC Login Protect Check
This repository contains a script to verify if the IAM users under the account have MFA enabled.

# Pre-requisites
You first need to install `jq` and `hcloud` -- Huawei's CLI.
jq: https://jqlang.org/download/
hcloud: https://support.huaweicloud.com/intl/pt-br/qs-hcli/hcli_02_003_02.html  

# **Resolving `[OPENAPI_ERROR]` in the CLI**

If you encounter the error `[OPENAPI_ERROR]` while using the `hcloud` command-line interface (CLI)

To resolve this issue, you need to switch the CLI back to **online mode**. You can do this by running the following command in your terminal:

```bash
hcloud configure set --cli-offline=false
