# CA based on the OpenSSL CLI called from Python
This repository has the code for a certificate authority (CA) based on the
OpenSSL command line interface (CLI) called from Python.

# Usage
Create new user certificates, for example if the current certificates have
expired by running the script like this.

    cd /where/you/cloned/workspace-ONE-PIV-D-manager-samples/ca-openssl-cli
    python3 -m certauth -p a,e,s user01@example.com

That will delete and replace the `user01` user certificates in your
`example.com/` depot directory.

**First time only** create your CA and a user certificate by running the script
like this.

    cd /where/you/cloned/workspace-ONE-PIV-D-manager-samples/ca-openssl-cli
    python3 -m certauth --create -p a,e,s user01@example.com

That will delete and recreate your `example.com/` depot directory and everything
under it.

Passcode for any PFX file will be the client name. For example, the
`example.com/user01_Auth.pfx` file has `user01` as its passcode.

# Full usage
To print the full usage message, run the script like this.

    cd /where/you/cloned/workspace-ONE-PIV-D-manager-samples/ca-openssl-cli
    python3 -m certauth -h

# Links
These links were referred to during coding so tip o' the hat (TOTH) to all.

https://arminreiter.com/2022/01/create-your-own-certificate-authority-ca-using-openssl/

Some list of openssl commands for check and verify your keys
https://gist.github.com/Hakky54/b30418b25215ad7d18f978bc0b448d81

# Backlog
Backlog of work items to do is in the [backlog.md](backlog.md) file.

# Other tools

-   XCA https://hohnstaedt.de/xca/  
    Seems like you have to create a database in order to do anything even
    inspect a certificate.

-   KeyStore Explorer https://keystore-explorer.org/

    https://github.com/kaikramer/keystore-explorer/issues/422

# License
Copyright 2023 VMware, Inc. All rights reserved.  
The Workspace ONE PIV-D Manager integration samples are licensed under a
two-clause BSD license.  
SPDX-License-Identifier: BSD-2-Clause