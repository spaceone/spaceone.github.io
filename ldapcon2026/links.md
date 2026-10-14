---
layout: default
title: Univention @ LDAPCon 2026 link collection
description: Links, references, and additional material for my LDAPCon 2026 talk
---
Links, references, and additional material for my LDAPCon 2026 talk **"Tales from integrating OpenLDAP with the modern world"**.

### 🎤 Talk materials

- [Presentation (PDF)](./Florian-Best-Tales-from-integrating-LDAP-LDAPCon-2026.pdf)  <!-- TODO: replace with upstream hosted link -->
- [Presentation (HTML)](./index.html) - use a recent Chromium; not old Firefox!
- [Talk transcript](./transcript.html)
- [Presentation (MARP markdown)](https://github.com/spaceone/spaceone.github.io/blob/main/ldapcon2026/Florian-Best-LDAPCon2026-Tales-from-integrating-LDAP.md)

### 🔐 CrudeOAuth

A SASL plugin and PAM implementation of **OAUTHBEARER** - enabling OAuth 2.0 access tokens for services such as OpenLDAP.

- [View `univention/crudeoauth` on GitHub](https://github.com/univention/crudeoauth)

Inspired by **CrudeSAML**, which provides a similar approach for SAML authentication:

- [CrudeSAML](https://ftp.espci.fr/pub/crudesaml/)

And, since it's *free as in bearer*:

- [Why Open Source misses the point of Free Software](https://www.gnu.org/philosophy/open-source-misses-the-point.en.html)

### 🧬 Distinguished Name (DN) Handling

Notes and examples about the surprisingly subtle details of handling and comparing LDAP Distinguished Names.

- [Read the FreeIAM documentation](https://docs.freeiam.org/en/latest/examples/ldap_dn.html)

The pragmatic approach:

- [Issue #257: `ldap.dn.dn2str()` does not support flags](https://github.com/python-ldap/python-ldap/issues/257)
- [PR #466: feat(ldap.dn): Add support for different formats in `ldap.dn2str()` via flags](https://github.com/python-ldap/python-ldap/pull/466)

### 🔗 In-Chain Matching for OpenLDAP

A new OpenLDAP contrib overlay, **`inchain`**, implementing Microsoft’s **LDAP_MATCHING_RULE_IN_CHAIN** (OID `1.2.840.113556.1.4.1941`) for recursive matching across LDAP Distinguished Name references.

- [View our OpenLDAP overlay prototype on GitHub](https://github.com/univention/openldap/pull/1)
- [OpenLDAP Issue 9402: Add support for `LDAP_MATCHING_RULE_IN_CHAIN`](https://bugs.openldap.org/show_bug.cgi?id=9402)

### 🛡️ Working with OpenLDAP Set ACLs

A practical article about OpenLDAP set-based ACLs.

- [Read the article on Arvids Blog](https://areq.gitlab.io/posts/2021-05-16-openldap-set-acls/)

### 📊 LDAP ACL performance comparisons

A broader overview of our LDAP ACL performance benchmarks and comparisons is still being prepared for publication.

It is not available yet, but I plan to add it here in the weeks following LDAPCon 2026.

### 🔐 OpenLDAP ACL Security & DIT Content Rules

References for the LDAP ACL quiz and two surprising behaviors with potentially serious security implications.

**Add Content ACLs:** By default, OpenLDAP does not perform attribute-level ACL checks when adding entries. Administrators may unknowingly allow the creation of entries containing otherwise restricted attributes.

- [`slapd.conf(5)` - `add_content_acl`](https://man7.org/linux/man-pages/man5/slapd.conf.5.html)
- [`slapd.access(5)` - ACL requirements for Add operations](https://man7.org/linux/man-pages/man5/slapd.access.5.html)
- [OpenLDAP ITS#10623 - Enable `add_content_acl` by default](https://bugs.openldap.org/show_bug.cgi?id=10623)
- [Security PoC - Add Content ACL bypass](https://github.com/spaceone/spaceone.github.io/tree/main/ldapcon2026/01_add_content_acl)

**Object Class ACLs:** The `@objectClass` ACL shortcut unexpectedly grants write access to arbitrary `objectClass` values, potentially allowing users to assign themselves privileged roles or remove security-relevant classifications.

- [OpenLDAP ITS#10638 - Restrict `@objectClass` ACL permissions](https://bugs.openldap.org/show_bug.cgi?id=10638)
- [Security PoC - Object class privilege escalation](https://github.com/spaceone/spaceone.github.io/tree/main/ldapcon2026/02_at_objectclass_write/)

**DIT Content Rules:** Additional schema constraints can restrict which auxiliary object classes are allowed, but cannot enforce mutual exclusion between them.

- [OpenLDAP FAQ: DIT Content Rules](https://www.openldap.org/faq/data/cache/1473.html)

### 🐛 Misc linked issues

- [ITS 9795 - Remove memberof overlay](https://bugs.openldap.org/show_bug.cgi?id=9795#c1)

### 👤 Contact details

- 📧 `best` + `@` + `univention.de`
- https://github.com/spaceone/

### 💼 Career at Univention

Interested in open source, identity management, and digital sovereignty?

- [Your next job might be at Univention](https://www.univention.com/about-us/careers/)

### 🕵️ Hidden reference: WeChall

[WeChall](https://www.wechall.net) is a hacking challenge platform where I built a large part of my practical security knowledge over the years.

It is not mentioned in the talk itself, but there is a small hidden reference: the T-shirt I'm wearing during the security chapters.
