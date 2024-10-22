# Run with Python 3.9 or later.
"""File in the certauth module."""
#
# Uses the following recent Python features.
# -   Python 3.7 subprocess text output and capture_output.
# -   Python 3.9 Path().with_stem()
#
# Standard library imports, in alphabetic order.
#
# Module for OO path handling.
# https://docs.python.org/3/library/pathlib.html
from pathlib import Path
#
# Module for high-level file operations. Only used for directory tree removal.
# https://docs.python.org/3/library/shutil.html#shutil.rmtree
import shutil
#
# Module for spawning a process to run a command.
# https://docs.python.org/3/library/subprocess.html
import subprocess
#
# Module for the operating system interface. Only used to return an error in
# case an attempt is made to run this file as a standalone script.
# https://docs.python.org/3/library/sys.html
from sys import stderr, exit
#
# Local imports.
#
from certauth.certificate_purpose import CertificatePurpose
from certauth.certificate_configuration import CertificateConfiguration

atSign = "@"

class CertificateAuthority(CertificateConfiguration):

    # Properties that are set by the CLI.
    #
    @property
    def authorityStem(self):
        return self._authorityStem
    @authorityStem.setter
    def authorityStem(self, authorityStem):
        self._authorityStem = authorityStem
        self._setComputedProperties()

    @property
    def clients(self):
        return self._clients
    @clients.setter
    def clients(self, clients):
        self._clients = clients

    @property
    def copies(self):
        return self._copies
    @copies.setter
    def copies(self, copies):
        self._copies = copies

    @property
    def create(self):
        return self._create
    @create.setter
    def create(self, create):
        self._create = create

    @property
    def domain(self):
        return self._domain
    @domain.setter
    def domain(self, domain):
        self._domain = domain
        self._setComputedProperties()

    # The base class, CertificateConfiguration, also has CLI properties.

    # End of CLI properties.

    # Computed properties
    @property
    def authorityKeyPath(self):
        return self._authorityKeyPath

    @property
    def authorityCertPath(self):
        return self._authorityCertPath

    @property
    def authoritySerialPath(self):
        return self._authoritySerialPath

    @property
    def depotPath(self):
        return self._depotPath

    # End of computed properties.

    def _setComputedProperties(self):
        # try:
        #     self._depotPath = Path(self._depot)
        # except AttributeError:
        #     pass
        
        try:
            self._depotPath = Path(self._domain)
        except AttributeError:
            pass

        try:
            authorityStem = Path(self._depotPath, self._authorityStem).resolve()
            self._authorityKeyPath = authorityStem.with_suffix(".key")
            self._authorityCertPath = authorityStem.with_suffix(".cer")
            self._authoritySerialPath = authorityStem.with_suffix(".srl")
        except AttributeError:
            pass

    def createAuthority(self):
        # Following code is a handy reminder how to raise built-in exceptions
        # but this wasn't needed here because shutil.rmtree will raise an
        # exception if called on a plain file.
        #
        # if not self.depotPath.is_dir():
        #     # TOTH how to raise built-in exceptions
        #     # https://stackoverflow.com/a/36077407/7657675
        #     raise FileExistsError(
        #         errno.EEXIST, os.strerror(errno.EEXIST), str(self.depotPath))

        try:
            shutil.rmtree(self.depotPath)
            print(f'Deleted depot directory "{self.depotPath.resolve()}"')
        except FileNotFoundError:
            pass

        print(f'Creating depot directory "{self.depotPath.resolve()}"')
        self.depotPath.mkdir(parents=True)
        commonName = f'{self.authorityStem}.{self.domain}'

        # https://www.ibm.com/docs/en/ibm-mq/7.5?topic=certificates-distinguished-names
        caCertCompleted = subprocess.run([
            "openssl", "req", "-x509", "-new", "-nodes", "-batch", "-sha256"
            , "-newkey", "rsa:2048", "-keyout", str(self.authorityKeyPath)
            , "-out", str(self.authorityCertPath)
            , "-subj", f'/CN={commonName}/C={self.countryCode}'
            f'/ST={self.stateName}/L={self.localityName}'
            f'/O={self.organisationName}/OU={self.organisationalUnitName}'
        ])
        runOK = caCertCompleted.returncode == 0
        print(" ".join((
            "Generated" if runOK else "Failed to generate",
            "authority certificate and key.",
            f"Return code {caCertCompleted.returncode}.")))
        return runOK
    
    def createClient(self, clientName, cnfPath, suffix):
        clientStem = cnfPath.with_stem(cnfPath.stem + suffix)
        forClient = f'For "{clientStem.stem}" '

        clientKeyPath = clientStem.with_suffix(".key.pem")
        clientCSR_Path = clientStem.with_suffix(".csr.pem")
        csrCompleted = subprocess.run([
            "openssl", "req", "-new", "-nodes"
            , "-newkey", "rsa:2048", "-keyout", str(clientKeyPath)
            , "-out", str(clientCSR_Path), "-config", str(cnfPath)
        ])
        print(forClient + f'CSR and key {csrCompleted.returncode}.')
        # Handy command to check the CSR, for key usages for example.
        #
        #     openssl req -in example.com/user01.csr.pem -text

        clientCertPath = clientStem.with_suffix(".cer.pem")
        signingCompleted = subprocess.run([
            "openssl", "x509", "-req", "-in", str(clientCSR_Path)
            , "-CAserial", str(self.authoritySerialPath), "-CAcreateserial"
            , "-CA", str(self.authorityCertPath)
            , "-CAkey", str(self.authorityKeyPath)
            , "-out", str(clientCertPath)
            # Add the CNF here, as well as in the csr step, because there
            # doesn't seem to be an equivalent to copy_extensions in the openssl
            # x509 command.
            , "-extfile", str(cnfPath)
        ])
        print(forClient + f'signing {signingCompleted.returncode}.')

        # TOTH how to create a PFX that includes the chain of trust.
        # https://stackoverflow.com/a/18830742/7657675
        clientPEM_Completed = subprocess.run([
            "openssl", "x509" , "-in", str(clientCertPath)
        ], stdout=subprocess.PIPE, text=True)
        chainPEM = clientPEM_Completed.stdout
        print(forClient + f'PEM {clientPEM_Completed.returncode}.')

        authorityPEM_Completed = subprocess.run([
            "openssl", "x509" , "-in", str(self.authorityCertPath)
        ], stdout=subprocess.PIPE, text=True)
        chainPEM += authorityPEM_Completed.stdout
        print(forClient + f'authority PEM {authorityPEM_Completed.returncode}.')

        # https://stackoverflow.com/questions/21141215/creating-a-p12-file#comment55842075_21141215
        clientExportPath = clientStem.with_suffix(".pfx")
        clientExportCompleted = subprocess.run([
            "openssl", "pkcs12", "-export", "-nodes"
            , "-inkey", str(clientKeyPath)
            , "-out", str(clientExportPath)
            , "-passout", f"pass:{clientName}"
        ], input=chainPEM, text=True)
        print(forClient + f'export {clientExportCompleted.returncode}.')

    def _client_name_and_email(self, client):
        (clientName, clientAt, clientDomain) = client.partition(atSign)
        email = "".join((
            clientName, atSign, self.domain)) if clientAt == "" else client
        return clientName, email

    def __call__(self):
        if self.create:
            if not self.createAuthority():
                return 1

        if not self.parsePurposesSpecifier():
            print('Failed to parse certificate purposes.')
            return 2

        created = 0
        for client in self.clients:
            tail = f' for "{client}" ...'
            purposes = len(self.certificatesPurposes)
            if self.copies > 1:
                print(
                    f'Creating {self.copies} x {purposes} certificates' + tail)
            else:
                if purposes > 1:
                    print(f'Creating {purposes} certificates' + tail)
                else:
                    print('Creating certificate' + tail)

            clientName, email = self._client_name_and_email(client)
            for cnfPath in self.write_client_CNFs(
                self.depotPath, clientName, email
            ):
                if self.copies <= 1:
                    self.createClient(clientName, cnfPath, "")
                    created += 1
                else:
                    for copy in range(1, self.copies + 1):
                        print(f'Creating copy {copy}' + tail)
                        self.createClient(clientName, cnfPath, f"{copy}")
                        created += 1

        print(f"Certificates created: {created}.")
        return 0

if __name__ == '__main__':
    stderr.write(
        "This file can only be run as a module, like `python -m certauth`\n")
    exit(1)
