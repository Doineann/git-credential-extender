# git-credential-extender
Script that modifies the key/value pairs passed to Git’s credential-helper system to allow that credentials are stored and retrieved on a per-repository basis.

## Purpose
When Git interacts with a credential manager (e.g., KWallet), it uses key/value
pairs to identify and store credentials. However, if there is no path specified after
the the host/domain, then a key might fail to uniquely identify a repository.
This results in credentials being applied to the entire domain (e.g., github.com),
making it impossible to store different credentials for multiple repositories on the
same host/domain with the same username.

This script resolves this by ensuring the `path` field contains the full repository path,
extracted from the remote URL, so credentials are managed individually for each repository.

## How it works under the hood
Suppose you are cloning `https://github.com/example-user/example-repo.git`.

When Git interacts with the credential manager during this process, it might pass or receive:
```
    protocol=https
    host=github.com
    path=/
```
This script transforms this into:
```
    protocol=https
    host=github.com
    path=/example-user/example-repo.git
```
So the full identifying key becomes:
    `https://github.com/example-user/example-repo.git`
instead of:
    `https://github.com/`

This ensures credentials are stored and retrieved uniquely for each repository and allows you 
to store multiple username/password comibations with the same username on a specific host/domain.

## Usage

1. Save this script somewhere on your system, e.g.:
      `/path/to/git-credential-key-extender.sh`
2. Make sure it is executable:
      `chmod +x /path/to/git-credential-key-extender.sh`
3. Configure Git:
      `git config --global credential.helper /path/to/git-credential-key-extender.sh`
4. Perform Git operations (e.g., clone, push, pull) and verify that credentials are
   stored/retrieved on a per-repository basis by using the full repository URL.
