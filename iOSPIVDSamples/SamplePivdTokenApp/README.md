
# Sample CTK Consumer application for iOS

**SamplePivdTokenApp** is an iOS sample application that showcases how to use keys accessed via a Persistent Token Extension by including **com.apple.token** in the app's entitlements file and using basic KeyChain API calls to sign, verify, encrypt, and decrypt. This demo app is designed to work in conjunction with CTK Provider apps like [Workspace One PIV-D Manager application](https://apps.apple.com/us/app/piv-d-manager-workspace-one/id1225667504).

Starting with macOS 10.15.4, iPadOS 14, and iOS 14, CryptoTokenKit has been extended to include support for persistent tokens, enabling access to tokens from Hardware Security Modules (HSMs) available through NFC (via the CoreNFC API), Secure Enclave, and other network-accessible locations. 

In this use case, a token hosting application like PIV-D manager application allows the system to address and use available tokens, address and use identities available by accessing tokens, and to access additional configuration information about tokens. iOS and iPadOS support for third-party apps requires a keychain entitlement referencing com.apple.token.

The Demo app mainly focuses on the following:

- Requesting access to credentials token available in the device.
- OS prompts with a dialog to allow provider apps credentials access to the user.
- On allowing access, CTK consumer app can use the services of CTK Persistent token extension to authenticate, sign, and decrypt information using available crypto APIs.

**Note** that the demo app is targeted to devices with iPadOS 14 and iOS 14 and above.

The sample app demonstrates the following operations:

- Signing: The app accepts a message from the user using an alert prompt, signs the message using the private key (accesses using Persistent token extension APIs), and verifies it using the public key.
- Decryption: The app encrypts information using a public key and then decrypts the encrypted information using the private key (accesses using Persistent token extension APIs). It then verifies that the message is decrypted to provide the original information.
- Authentication: The app can also demonstrate integrated authentication (IA) tied to a URL. The user can choose to have the request processed in WKWebView or via URLSession. 

Note: Please change the URL tied to your certificate in the `Utility.swift class` - `Constants.iaURl`
