# Run with Python 3
"""Script to create certificates with the openssl CLI.

Certificate authority (CA) and client certificate files will be generated in a
depot directory. Intermediate files will be retained, also in the depot.

The script takes a list of client specifiers for which to generate certificates
on the command line. For each client specifier:

-   If the specifier is an email address then the client name will be the
    portion before the at sign.
-   Otherwise the whole specifier is the client name. An email address for the
    certificate will be composed by appending an at sign, and an internet domain
    to the client name.

PFX files for client certificates will be passcode-protected. The passcode will
be the client name.

The script can take a list of certificate purpose specifiers too. By example:

-   "AuthEncryptSign", the default, specifies one certificate with the purposes
    Authentication, Encryption, and Signature.
-   "aes" is a short form of "AuthEncryptSign".
-   "Auth,EncryptSign" specifies two certificates.
    -   First has the purpose Authentication.
    -   Second has the purposes Encryption and Signature.
-   "a,es" is a short form of "Auth,EncryptSign".

The script generates a certificate set for each client."""

# This file makes a runnable module. To get the command line usage, run it like
# this.
#
#     cd /where/you/cloned/workspace-ONE-PIV-D-manager-samples/ca-openssl-cli
#     python3 -m certauth --help

#
# Standard library imports, in alphabetic order.
# 
# Module for command line switches.
# Tutorial: https://docs.python.org/3/howto/argparse.html
# Reference: https://docs.python.org/3/library/argparse.html
import argparse
#
# Module for the operating system interface.
# https://docs.python.org/3/library/sys.html
from sys import argv, exit
#
# Module for text dedentation.
# Only used for --help description.
# https://docs.python.org/3/library/textwrap.html
import textwrap
#
# Local imports.
#
# The main code, CertificateAuthority, and purpose helper, CertificatePurpose.
from certauth.certificate_authority import CertificateAuthority
from certauth.certificate_purpose import CertificatePurpose
# Dot notation can be used because there is an __init__.py file in this
# directory.

# TOTH Enforcing conditions on argparse values
# https://stackoverflow.com/a/18700817/7657675
class CountryCodeAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if len(values) > 2:
            parser.error(
                f'Country code "{values}" set by {option_string} too long.'
                f" Length:{len(values)}. Maximum length: 2.")
        setattr(namespace, self.dest, values)

def main(commandLine):
    argumentParser = argparse.ArgumentParser(
        prog="python3 -m certauth",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent(__doc__))
    argumentParser.add_argument(
        '--create', action='store_true', help=
        "Create a new authority and delete the depot directory if it exists."
        " Default is to leave the current depot and authority in place.")
    argumentParser.add_argument(
        '--copies', default=1, type=int, help=
        'Create multiple copies of each certificate.'
        ' Each copy has its own private key. Default: 1.')
    argumentParser.add_argument(
        '-d', '--domain', default="example.com", type=str, help=
        'Internet domain to append to any client names that ' "aren't" ' email'
        ' addresses. Also used as the name of the depot directory.'
        ' Default: "example.com"')
    argumentParser.add_argument(
        '--authority-stem', dest='authorityStem', default="authority"
        , type=str, help="Stem for CA file names. Also used in the CA"
        " certificate's common name. Default: " '"authority"')
    argumentParser.add_argument(
        '--country-code', dest='countryCode', default="UK"
        , action=CountryCodeAction, type=str, help=
        'Country code for all certificates. Maximum length: 2. Default: "UK"')
    argumentParser.add_argument(
        '--state-name', dest='stateName', default="Example State", type=str
        , help='State name for all certificates. Default: "Example State"')
    argumentParser.add_argument(
        '--locality-name', dest='localityName', default="Example Locality"
        , type=str, help=
        'Locality name for all certificates. Default: "Example Locality"')
    argumentParser.add_argument(
        '--organisation-name', '--organization-name', dest='organisationName'
        , default="Example Organisation", type=str, help=
        'Organisation name for all certificates. Default:'
        ' "Example Organisation"')
    argumentParser.add_argument(
        '--organisational-unit-name', '--organizational-unit-name'
        , dest='organisationalUnitName', default="Example Unit", type=str, help=
        'Organisational unit name for all certificates.'
        ' Default: "Example Unit"')
    argumentParser.add_argument(
        '-p', '--purposes', dest='purposesSpecifier', metavar='SPECIFIER'
        , default=CertificatePurpose.humanSuffixes(), type=str, help=
        'Specifier for certificate purposes.'
        f' Default: "{CertificatePurpose.humanSuffixes()}"')
    argumentParser.add_argument(
        dest='clients', metavar='client', default=["user01"], type=str
        , nargs='*', help=
        "Client names to generate certificate for."
        ' Default: "user01"')
    return argumentParser.parse_args(commandLine[1:], CertificateAuthority())()

exit(main(argv))
