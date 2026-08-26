# Phase 00 – Bootstrap

## 1. Objective

Prepare every virtual machine immediately after provisioning so it can be managed securely, consistently and reproducibly by Ansible.

Bootstrap establishes the minimum operating system configuration required before any configuration management tasks are executed.

---

## 2. Scope

This phase is responsible for:

- Creating the automation user.
- Preparing the SSH environment.
- Installing the laboratory public key.
- Configuring passwordless sudo for automation.
- Removing temporary provisioning artifacts.

This phase does not install packages, configure services or deploy cluster software.

---

## 3. Responsibilities

Bootstrap provides a secure and predictable baseline for every virtual machine.

Once completed, every node exposes the same administrative interface regardless of its future role within the cluster.

---

## 4. Inputs

Bootstrap requires:

- A freshly provisioned Rocky Linux virtual machine.
- Root privileges during provisioning.
- The laboratory public SSH key.
- The `bootstrap.sh` script.

---

## 5. Outputs

After successful execution:

- The `ansible` user exists.
- The user's home directory is available.
- SSH authentication is configured.
- Passwordless sudo is available.
- Temporary provisioning files have been removed.

---

## 6. Security Assumptions

Bootstrap assumes that:

- Provisioning occurs in a trusted environment.
- The laboratory public key is distributed securely.
- The private SSH key never leaves the administrator workstation.
- Root access is required only during provisioning.

---

## 7. Contract

The following phases may assume that every managed node:

- Can be reached through SSH using the automation key.
- Accepts passwordless sudo from the `ansible` user.
- Shares the same administrative baseline.
- Is ready to be managed exclusively through Ansible.

---

## 8. Validation

Bootstrap is considered successful when:

- The `ansible` account exists.
- SSH login using the automation key succeeds.
- `sudo -n true` executes successfully.
- Temporary provisioning files are no longer present.

---

## 9. Design Decisions

- Bootstrap performs only operating system preparation.
- Configuration management is intentionally delegated to Ansible.
- Temporary provisioning files are removed before completion.
- Security is established before any service deployment.

---

## 10. Known Limitations

- Bootstrap assumes Rocky Linux 9.
- Passwordless sudo is enabled for the automation account.
- Package installation is intentionally outside the scope of this phase.

---

## 11. Future Improvements

Possible future enhancements include:

- Distribution-aware bootstrap logic.
- Automatic operating system validation.
- Bootstrap execution logging.
- Integrity verification of the distributed public key.