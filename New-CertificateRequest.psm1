################################################################################
#
# Copyright (c) 2011-2016 Seth Wright <seth@crosse.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
################################################################################

################################################################################
<#
    .SYNOPSIS
    Creates a new certificate request.

    .DESCRIPTION
    Creates a new certificate request and returns the Base64-encoded request text
    suitable for submitting to a third-party certificate authority.  The
    certificate request is also stored in either the user's or the machine's
    certificate store, and can be completed using the Complete-CertificateRequest
    cmdlet.

    There are also convenience cmdlets for each certificate type:
        - New-ServerCertificateRequest
        - New-ClientCertificateRequest
        - New-SmimeCertificateRequest
        - New CodeSigningCertificateRequest

    .INPUTS
    None
        You cannot pipe objects to the cmdlet.

    .OUTPUTS
    System.String.  New-CertificateRequest returns the generated X509,
    Base64-encoded certificate request that can be submitted to a third-
    party certificate authority.

    .EXAMPLE
    C:\PS> New-CertificateRequest -ServerCertificate -CommonName "server.contoso.com"
    -----BEGIN NEW CERTIFICATE REQUEST-----
    [...]
    -----END NEW CERTIFICATE REQUEST-----

    The above example generates a certificate request suitable for use on a web
    server named "server.contoso.com".

    .EXAMPLE
    C:\PS> New-CertificateRequest -ServerCertificate -KeyLength 4096 -CommonName "server.contoso.com"
    -----BEGIN NEW CERTIFICATE REQUEST-----
    [...]
    -----END NEW CERTIFICATE REQUEST-----

    The above example generates a certificate request suitable for use on a web
    server named "server.contoso.com", and requests a key length of 4096 bits.

    .EXAMPLE
    C:\PS> New-CertificateRequest -ServerCertificate -SubjectName "CN=server.contoso.com, OU=IT Department, O=Contoso, L=Example City, S=Washington, C=US"
    -----BEGIN NEW CERTIFICATE REQUEST-----
    [...]
    -----END NEW CERTIFICATE REQUEST-----

    The above example generates a certificate request suitable for use on a web
    server named "server.contoso.com".  It also shows how to manually specify the
    SubjectName of the certificate instead of using the convenience parameters.

    .EXAMPLE
    C:\PS> New-CertificateRequest -SmimeCertificate -EmailAddress "asdf@asdf.com" -CommonName "Joe User"
    -----BEGIN NEW CERTIFICATE REQUEST-----
    [...]
    -----END NEW CERTIFICATE REQUEST-----

    The above example generates a certificate request suitable for use as an
    S/MIME certificate for email protection.  You can also use the
    New-SmimeCertificateRequest cmdlet as a convenience.

    .EXAMPLE
    C:\PS> New-CertificateRequest -CodeSigningCertificate -EmailAddress "asdf@asdf.com" -CommonName "Joe User"
    -----BEGIN NEW CERTIFICATE REQUEST-----
    [...]
    -----END NEW CERTIFICATE REQUEST-----

    The above example generates a certificate request suitable for use as an
    object- or code-signing certificate.  You can also use the
    New-CodeSigningCertificateRequst cmdlet as a convenience.
#>
################################################################################
function New-CertificateRequest {
    [CmdletBinding()]
    param (
            [Parameter(Mandatory=$true, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSACodeSigningCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSAServerCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="RSAClientCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="RSASmimeCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="RSACodeSigningCertificateExplicitSubject")]
            [switch]
            # Generate an RSA certificate request.
            $RSA,

            [Parameter(Mandatory=$true, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCSmimeCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCCodeSigningCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCServerCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCClientCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCSmimeCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCCodeSigningCertificateExplicitSubject")]
            [switch]
            # Generate an ECC (ECDSA) certificate request.
            $ECC,

            [Parameter(Mandatory=$false)]
            [ValidateSet(256, 384, 521, 2048, 4096, 8192, 16384)]
            [int]
            # The length of the key in bits.
            # For RSA certificates, the default is 2048. Valid values for RSA certificates are 2048, 4096, 8192, and 16384.
            # For ECC certificates, the default is 256. Valid values for ECC certificates are 256, 384, or 521.
            $KeyLength = -1,

            [Parameter(Mandatory=$true, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSAServerCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCServerCertificateExplicitSubject")]
            [switch]
            # Specifies that this should be a server certificate.
            $ServerCertificate,


            [Parameter(Mandatory=$true, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSAClientCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCClientCertificateExplicitSubject")]
            [switch]
            # Specifies that this should be a client certificate.
            $ClientCertificate,

            [Parameter(Mandatory=$true, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSASmimeCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCSmimeCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCSmimeCertificateExplicitSubject")]
            [switch]
            # Specifies that this should be an S/MIME (email) certificate.
            $SmimeCertificate,

            [Parameter(Mandatory=$true, ParameterSetName="RSACodeSigningCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSACodeSigningCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCCodeSigningCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCCodeSigningCertificateExplicitSubject")]
            [switch]
            # Specifies that this should be a code-signing certificate.
            $CodeSigningCertificate,

            [Parameter(Mandatory=$true, ParameterSetName="RSAServerCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="RSAClientCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="RSASmimeCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="RSACodeSigningCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCServerCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCClientCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCSmimeCertificateExplicitSubject")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCCodeSigningCertificateExplicitSubject")]
            [ValidateNotNullOrEmpty()]
            [string]
            # Used to manually specify the full distinguished name that will be used for the certificate's Subject field.
            $SubjectName,

            [Parameter(Mandatory=$false, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCSmimeCertificate")]
            [ValidateNotNullOrEmpty()]
            [string]
            # The entity's email address.
            $EmailAddress,

            [Parameter(Mandatory=$true, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="RSACodeSigningCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCSmimeCertificate")]
            [Parameter(Mandatory=$true, ParameterSetName="ECCCodeSigningCertificate")]
            [ValidateNotNullOrEmpty()]
            [string]
            # The common name of the entity.  For a server certificate, this could be the server name.  For a client certificate, this could be the user's email address or user name.
            $CommonName,

            [Parameter(Mandatory=$false, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSACodeSigningCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCSmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCCodeSigningCertificate")]
            [ValidateNotNullOrEmpty()]
            [string]
            # The department or organizational unit in charge of the entity.
            $OrganizationalUnit,

            [Parameter(Mandatory=$false, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSACodeSigningCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCSmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCCodeSigningCertificate")]
            [ValidateNotNullOrEmpty()]
            [string]
            # The organzation or company in charge of the entity.
            $Organization,

            [Parameter(Mandatory=$false, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSACodeSigningCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCSmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCCodeSigningCertificate")]
            [ValidateNotNullOrEmpty()]
            [string]
            # The city (or locality) in which the organization resides.
            $Locality,

            [Parameter(Mandatory=$false, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSACodeSigningCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCSmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCCodeSigningCertificate")]
            [ValidateNotNullOrEmpty()]
            [string]
            # The non-abbreviated state or province in which the organization resides.
            $State,

            [Parameter(Mandatory=$false, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSAClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSASmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSACodeSigningCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCClientCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCSmimeCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCCodeSigningCertificate")]
            [ValidateNotNullOrEmpty()]
            [ValidateLength(2, 2)]
            [string]
            # The 2-letter abbreviation of the country in which the organization resides.
            $Country,

            [Parameter(Mandatory=$false, ParameterSetName="RSAServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="RSAServerCertificateExplicitSubject")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCServerCertificate")]
            [Parameter(Mandatory=$false, ParameterSetName="ECCServerCertificateExplicitSubject")]
            [ValidateNotNullOrEmpty()]
            [string[]]
            # An array of alternative DNS names that should be bound to the
            # certificate's public key.  This can only be used for a server
            # certificate currently.
            $SubjectAlternateNames,

            [Parameter(Mandatory=$false)]
            [string]
            # An optional friendly name for the certificate.
            $FriendlyName,

            [Parameter(Mandatory=$false)]
            [string]
            # An optional description of the certificate.
            $Description
          )

    BEGIN {
        # The "magic numbers" section.
        # There is no really good reason for all these to be in the BEGIN
        # block, except that it sets these contant-value-type things apart
        # from the actual code, where I can document them all in one place.

        if ($KeyLength -eq -1) {
            if ($ECC) { $KeyLength = 256 }
            if ($RSA) { $KeyLength = 2048 }
        }

        if ($ECC -and $KeyLength -gt 521) {
            throw "Valid Key Length for ECC certificates are: 256, 384, 521."
        }
        if ($RSA -and $KeyLength -lt 2048) {
            throw "Valid Key Length for RSA certificates are: 2048, 4096, 8192, 16384."
        }

        # The name of the cryptographic provider.  Specifying this also sets the
        # key's ProviderType.  
        if ($RSA) {
            # In this case, the ProviderType is XCN_PROV_RSA_SCHANNEL.
            # http://msdn.microsoft.com/en-us/library/windows/desktop/aa379427.aspx
            $ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
        } else {
            # For ECC certificates, a little more work has to be done, but this is the
            # provider name.
            $ProviderName = "Microsoft Software Key Storage Provider"
        }

        # This is an SDDL string specifying that the
        # NT AUTHORITY\SYSTEM and the BUILTIN\Administrators group have
        # basically all rights to the private key, and that
        # NT AUTHORITY\NETWORK SERVICE has Read, List, and Create Child rights.
        # See the big scariness here:
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa772285.aspx
        $ServerCertificateSDDL = "D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)"

        # The following gets the default SDDL string for use with a user
        # certificate.  It ensures that NT AUTHORITY\SYSTEM and the
        # BUILTIN\Administrators group have all rights to the private key,
        # and that the current user has all rights to the key as well.
        # Read more here:
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa376741.aspx
        $info = New-Object -ComObject X509Enrollment.CCspInformation.1
        $info.InitializeFromName($ProviderName)
        $ClientCertificateSDDL = $info.GetDefaultSecurityDescriptor($false)

        # This is a X509KeySpec enum value that states that "the key can be
        # used to encrypt (including key exchange) or sign depending on the
        # algorithm."
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa379409.aspx
        # X509KeySpec:
        #   XCN_AT_NONE          = 0,
        #   XCN_AT_KEYEXCHANGE   = 1,
        #   XCN_AT_SIGNATURE     = 2
        $X509KeySpec= 1

        # This specifies that the private key can be exported.
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa379412.aspx
        # X509PrivateKeyExportFlags:
        #   XCN_NCRYPT_ALLOW_EXPORT_NONE                = 0,
        #   XCN_NCRYPT_ALLOW_EXPORT_FLAG                = 0x1,
        #   XCN_NCRYPT_ALLOW_PLAINTEXT_EXPORT_FLAG      = 0x2,
        #   XCN_NCRYPT_ALLOW_ARCHIVING_FLAG             = 0x4,
        #   XCN_NCRYPT_ALLOW_PLAINTEXT_ARCHIVING_FLAG   = 0x8
        $X509PrivateKeyExportFlagsAllowExport = 0x3

        # X509CertificateEnrollmentContext
        #   ContextUser                        = 0x1,
        #   ContextMachine                     = 0x2,
        #   ContextAdministratorForceMachine   = 0x3
        #
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa379399.aspx
        $X509CertEnrollmentContextUser      = 0x1
        $X509CertEnrollmentContextMachine   = 0x2

        # Requested Extensions:
        #   X509v3 Key Usage: critical
        #       Digital Signature, Non Repudiation, Key Encipherment, Data Encipherment
        #
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa379410.aspx
        # X509KeyUsageFlags:
        #   XCN_CERT_DIGITAL_SIGNATURE_KEY_USAGE   = 0x80
        #   XCN_CERT_NON_REPUDIATION_KEY_USAGE     = 0x40
        #   XCN_CERT_KEY_ENCIPHERMENT_KEY_USAGE    = 0x20
        #   XCN_CERT_DATA_ENCIPHERMENT_KEY_USAGE   = 0x10
        $ServerCertRequestedExtensions      = 0xF0  # 240
        $ClientCertRequestedExtensions      = 0xB0  # 176
        $CodeSigningCertRequestedExtensions = 0x80  # 128

        #   X509v3 Extended Key Usage:
        #       TLS Web Server Authentication
        #
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa378132.aspx
        #   XCN_OID_PKIX_KP_SERVER_AUTH = 1.3.6.1.5.5.7.3.1
        #       "The certificate can be used for OCSP authentication."
        #
        $XCNOidPkixKpServerAuth         = "1.3.6.1.5.5.7.3.1"
        $XCNOidPkixKpClientAuth         = "1.3.6.1.5.5.7.3.2"
        $XCNOidPkixKpCodeSigning        = "1.3.6.1.5.5.7.3.3"
        $XCNOidPkixKpEmailProtection    = "1.3.6.1.5.5.7.3.4"

        # The AlternativeNameType enum value specifying that an item in the
        # SubjectAlternativeNames list is a DNS name.
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa374830.aspx
        $XCNCertAltNameDnsName = 3

        # The EncodingType enum value specifying that the encoding should
        # be represented as a Certificate Request.  It puts the
        # -----BEGIN NEW CERTIFICATE REQUEST-----
        # -----END NEW CERTIFICATE REQUEST-----
        # text before and after the CSR.
        #
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa374936.aspx
        $XCNCryptStringBase64RequestHeader = 0x3

        # The algorithm names for ECC certificates.
        $ECDSA_Algorithms = @{}
        $ECDSA_Algorithms[256] = 371
        $ECDSA_Algorithms[384] = 372
        $ECDSA_Algorithms[512] = 373
    }

    PROCESS {
        # Build the Subject attribute.  Do this first so that if it fails,
        # we don't create a private key every time the user retries.
        if ([String]::IsNullOrEmpty($SubjectName)) {
            Write-Verbose "Constructing the SubjectName"
            $subject = "CN={0}" -f $CommonName

            if ([String]::IsNullOrEmpty($EmailAddress) -eq $false) {
                $subject = "E={0},{1}" -f $EmailAddress, $subject
            }

            if ([String]::IsNullOrEmpty($OrganizationalUnit) -eq $false) {
                $subject += ",OU={0}" -f $OrganizationalUnit
            }

            if ([String]::IsNullOrEmpty($Organization) -eq $false) {
                $subject += ",O={0}" -f $Organization
            }

            if ([String]::IsNullOrEmpty($Locality) -eq $false) {
                $subject += ",L={0}" -f $Locality
            }

            if ([String]::IsNullOrEmpty($State) -eq $false) {
                $subject += ",S={0}" -f $State
            }

            if ([String]::IsNullOrEmpty($Country) -eq $false) {
                $subject += ",C={0}" -f $Country
            }
        } else {
            Write-Verbose "Using user-supplied SubjectName"
            $subject = $SubjectName
        }

        Write-Verbose "Subject: $Subject"
        $distinguishedName = New-Object -ComObject "X509Enrollment.CX500DistinguishedName.1"
        $distinguishedName.Encode($subject)
        if ($distinguishedName.Name -eq $null) {
            Write-Error "Could not encode Subject value.  Ensure that it is of the proper format."
            return
        }

        # Create the private key.
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa378921.aspx
        $key = New-Object -ComObject "X509Enrollment.CX509PrivateKey.1"
        $key.ProviderName = $ProviderName
        $key.KeySpec = $X509KeySpec
        $key.ExportPolicy = $X509PrivateKeyExportFlagsAllowExport
        $key.Length = $KeyLength
        if ($ECC) {
            $algorithm = New-Object -ComObject "X509Enrollment.CObjectId.1"
            $algorithm.InitializeFromName($ECDSA_Algorithms[$KeyLength])
            $key.Algorithm = $algorithm
        }
        if ($ServerCertificate) {
            $key.MachineContext = $true
            # Use an SDDL appropriate for a server certificate.
            $key.SecurityDescriptor = $ServerCertificateSDDL
        } else {
            # Store the key in the user's store and use an SDDL
            # appropriate for a client certificate.
            $key.MachineContext = $false
            try {
                $key.SecurityDescriptor = $ClientCertificateSDDL
            } catch {
                Write-Warning "Unable to set SDDL on private key; this may not be a problem."
            }
        }

        $key.Create()
        if (!$key.Opened) {
            Write-Error "Could not create and open a private key."
            return
        }
        Write-Verbose "Created private key."

        # Initialize the Certificate Request.
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa377505.aspx
        $certreq = New-Object -ComObject "X509Enrollment.CX509CertificateRequestPkcs10.1"
        if ($Context -eq "Machine") {
            $certreq.InitializeFromPrivateKey($X509CertEnrollmentContextMachine, $key, $null)
        } else {
            $certreq.InitializeFromPrivateKey($X509CertEnrollmentContextUser, $key, $null)
        }

        $certreq.Subject = $distinguishedName

        $ExtensionKeyUsage = New-Object -ComObject "X509Enrollment.CX509ExtensionKeyUsage.1"
        if ($ServerCertificate) {
            # Add the Server Authentication EKU.
            Write-Verbose "Setting X509KeyUsageFlags == $ServerCertRequestedExtensions"
            $ExtensionKeyUsage.InitializeEncode($ServerCertRequestedExtensions)
            $ExtensionKeyUsage.Critical = $true
        } elseif ($ClientCertificate) {
            # Add the Client Authentication EKU.
            Write-Verbose "Setting X509KeyUsageFlags == $ClientCertRequestedExtensions"
            $ExtensionKeyUsage.InitializeEncode($ClientCertRequestedExtensions)
        } elseif ($SmimeCertificate) {
            Write-Verbose "Setting X509KeyUsageFlags == $ClientCertRequestedExtensions"
            # Add the S/MIME EKU.
            $ExtensionKeyUsage.InitializeEncode($ClientCertRequestedExtensions)
        } elseif ($CodeSigningCertificate) {
            Write-Verbose "Setting X509KeyUsageFlags == $CodeSigningCertRequestedExtensions"
            # Add the Code-Signing EKU.
            $ExtensionKeyUsage.InitializeEncode($CodeSigningCertRequestedExtensions)
        } else {
            Write-Error "Error setting Extension Key Usage:  could not determine certificate type!"
            if ($key.Opened) {
                $key.Close()
            }
            return
        }
        $certreq.X509Extensions.Add($ExtensionKeyUsage)

        # Create a collection to add EKUs to
        $EnhancedKeyUsageOids = New-Object -ComObject "X509Enrollment.CObjectIds.1"

        if ($ServerCertificate) {
            $ServerAuthEKU = New-Object -ComObject "X509Enrollment.CObjectId.1"
            $ServerAuthEKU.InitializeFromValue($XCNOidPkixKpServerAuth)
            $EnhancedKeyUsageOids.Add($ServerAuthEKU)
        } elseif ($CodeSigningCertificate) {
            $CodeSigningEKU = New-Object -ComObject "X509Enrollment.CObjectId.1"
            $CodeSigningEKU.InitializeFromValue($XCNOidPkixKpCodeSigning)
            $EnhancedKeyUsageOids.Add($CodeSigningEKU)
        } else {
            $ClientAuthEKU = New-Object -ComObject "X509Enrollment.CObjectId.1"
            $ClientAuthEKU.InitializeFromValue($XCNOidPkixKpClientAuth)
            $EnhancedKeyUsageOids.Add($ClientAuthEKU)

            # S/MIME is nested because both the Client Auth EKU and the
            # Email Protection EKU should be specified.  This is apparently
            # different from code-signing certs, which don't include the
            # client auth EKU.
            if ($SmimeCertificate) {
                $SmimeAuthEKU = New-Object -ComObject "X509Enrollment.CObjectId.1"
                $SmimeAuthEKU.InitializeFromValue($XCNOidPkixKpEmailProtection)
                $EnhancedKeyUsageOids.Add($SmimeAuthEKU)
            }

        }

        # Add the EKU collection to the CSR.
        $EnhancedKeyUsage = New-Object -ComObject "X509Enrollment.CX509ExtensionEnhancedKeyUsage.1"
        $EnhancedKeyUsage.InitializeEncode($EnhancedKeyUsageOids)
        $certreq.X509Extensions.Add($EnhancedKeyUsage)

        if ($ServerCertificate) {
            # We only handle Subject Alternate Names for Server certs right now.
            # If the user specified that the certificate should include
            # alternative names, add them to the CSR.
            $alternativeNames = $null
            if ($SubjectAlternateNames.Count -gt 0) {
                for ($i = 0; $i -lt $SubjectAlternateNames.Count; $i++) {
                    $name = $SubjectAlternateNames[$i]
                    $altName = New-Object -ComObject "X509Enrollment.CAlternativeName.1"
                    $altName.InitializeFromString($XCNCertAltNameDnsName, $name)
                    if ($alternativeNames -eq $null) {
                        $alternativeNames = New-Object -ComObject "X509Enrollment.CAlternativeNames.1"
                    }
                    $alternativeNames.Add($altName)
                    Write-Verbose "SubjectAlternativeName: DNS:$($name)"
                }
                if ($alternativeNames.Count -gt 0) {
                    $ExtensionAlternativeNames = New-Object -ComObject "X509Enrollment.CX509ExtensionAlternativeNames.1"
                    $ExtensionAlternativeNames.InitializeEncode($alternativeNames)
                    # Add the requested Subject Alternative Names to the certificate request.
                    $certreq.X509Extensions.Add($ExtensionAlternativeNames)
                }
            }
        }

        # The CX509Enrollment object is what actually puts the CSR into the
        # certificate store and prints out the CSR for submission to a CA.
        # http://msdn.microsoft.com/en-us/library/windows/desktop/aa377809.aspx
        $enrollment = New-Object -ComObject "X509Enrollment.CX509Enrollment.1"
        $enrollment.InitializeFromRequest($certreq)
        if ($enrollment.Request -eq $null) {
            Write-Error $enrollment.Status.ErrorText
            if ($key.Opened) {
                $key.Close()
            }
            return
        }

        if ([String]::IsNullOrEmpty($Description) -eq $false) {
            $enrollment.CertificateDescription = $Description
        }

        if ([String]::IsNullOrEmpty($FriendlyName) -eq $false) {
            $enrollment.CertificateFriendlyName = $FriendlyName
        }

        Write-Verbose "Creating Certificate Request"
        $csr = $enrollment.CreateRequest($XCNCryptStringBase64RequestHeader)
        if ($csr -eq $null) {
            Write-Error "Could not create the CSR: $($enrollment.Status.ErrorText)"
            if ($key.Opened) {
                $key.Close()
            }
            return
        } else {
            Write-Verbose "Certificate Request created."
        }

        if ($key.Opened) {
            Write-Verbose "Closing private key"
            $key.Close()
        }

        return $csr
    }
}