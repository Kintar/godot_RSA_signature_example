# USAGE

The first time you run the project, click "Generate KeyPair" to create a new random
public/private key pair.

1. Create some kind of example message you want to sign in an external text editor.
1. Click "Load Private Key". The top text field should say "Successfully loaded private key"
1. Clear the top text field and enter your message from step 1.
1. Click "Sign Message". The bottom text field will change to the hex-encoded signature value.
1. In case of errors, copy the signature into a new text editor.
1. Click "Load Public Key". The top text field should say "Successfully loaded public key".
1. Paste the message back into the top text field. Ensure the signature is still in the bottom field.
1. Click "Verify Signature".
1. The bottom field should change to "Signature verified!"

# Overview

This project shows that someone in possession of an RSA private key file can sign a message, then
pass that message and signature to someone in possession of the matching public key file. The public
key can then be used to verify the signature.

In order to sign or verify a signature, you must create a hash of the original message, which is then
used in the RSA signing function. This example program uses a SHA256 hash with a 1024-byte chunk size.

Generating a keypair results in two files in the project directory: "public.rsa" and "private.rsa".
Contents of these files are standard ASCII-armor and may be inspected by the end user.

During operation two `CryptoKey` variables are used, 'publicKey' and 'privateKey'. When one is loaded,
the other is nullified. This can be verified easily by reading the script in `main.gd`.

