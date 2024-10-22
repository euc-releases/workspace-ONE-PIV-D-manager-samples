# Backlog
Add support for setting a longer expiry time.

Maybe add testing of the certificates, for S/MIME for example see
https://www.misterpki.com/openssl-smime/

Review use of `critical` in key usage and extended key usage. Maybe it means
that a certificate can't be used for anything that isn't allowed "that which
isn't forbidden is allowed".  
-   See https://security.stackexchange.com/questions/17583/how-do-i-create-a-valid-email-certificate-for-outlook-s-mime-with-openssl#17601
-   https://security.stackexchange.com/a/264648

Add support for multiple rfc822 or multiple UPN or other multiples in the SAN or
wherever supported.

Add the required field and value for this.

-   https://support.microsoft.com/en-gb/topic/kb5014754-certificate-based-authentication-changes-on-windows-domain-controllers-ad2c23b0-15d8-4340-a468-4d4f3b188f16?utm_campaign=24Q2_IAM_Global_Customer-Notice_MSFT-CertAuth_Email&utm_medium=email&utm_source=Eloqua&edc_sfid=7015Y0000048249QAA#bkmk_compatmode

>   From Entrust  
>   The Full Enforcement mode requires, for newly issued certificates, checks of
>   the Object Identifier (OID) (1.3.6.1.4.1.3.11.26.2) extension against their
>   corresponding user account SID (Security Identifier) in AD/DC

Add an option to add the key to a pkcs7 aka p7b file and export to pfx. That
could be used to integrate with ADFS or other external CAs. Maybe the script
should read the CN from the pkcs7 file in order to determine the name of the
.key file. Handy command here.

    openssl pkcs7 -print_certs -in example.com/user01.p7b

Add a friendly name to client certificates, and CA certificates.  
See the `openssl` `pkcs12` CLI `-name` switch. Or maybe the `-setalias` switch,
see https://serverfault.com/a/103314.

Add an option to list the expiry dates of all the certificates in the store.
Here's a CLI to do that.

    openssl x509 -in example.com/user01_Auth.cer -noout -dates 

And see
https://www.ssl.com/how-to/export-certificates-private-key-from-pkcs12-file-with-openssl/

    openssl pkcs12 -info -in depot/user01.p12 -nodes

Add an option to load the certs onto a YubiKey using the ykman CLI.
https://docs.yubico.com/software/yubikey/tools/ykman/PIV_Commands.html

Add an option for EC keys instead of RSA keys.

Add more prominent error messages for when openssl returns an error.

See about using the ?new `openssl` `ca` command for signing and maybe CA
creation.
