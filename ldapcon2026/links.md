---
layout: default
title: LDAPCon 2026 Link collection
---
# Univention @ LDAPCon 2026 link collection

Links, references, and additional material for my LDAPCon 2026 talk **"Tales from integrating OpenLDAP with the modern world"**.

### 🎤 Talk materials

- [→ Presentation (PDF)](./Florian-Best-Tales-from-integrating-LDAP-LDAPCon-2026.pdf)  <!-- TODO: replace with upstream hosted link -->
- [→ Presentation (MARP HTML)](./index.html)
- [→ Talk transcript](./transcript.html)

### 🔐 CrudeOAuth

A SASL plugin and PAM implementation of **OAUTHBEARER** - enabling OAuth 2.0 access tokens for services such as OpenLDAP.

[→ View `univention/crudeoauth` on GitHub](https://github.com/univention/crudeoauth)

Inspired by **CrudeSAML**, which provides a similar approach for SAML authentication:

[→ CrudeSAML](https://ftp.espci.fr/pub/crudesaml/)

And, since it's *free as in bearer*:

[→ Why Open Source misses the point of Free Software](https://www.gnu.org/philosophy/open-source-misses-the-point.en.html)

### 🧬 Distinguished Name (DN) Handling

Notes and examples about the surprisingly subtle details of handling and comparing LDAP Distinguished Names.

[→ Read the FreeIAM documentation](https://docs.freeiam.org/en/latest/examples/ldap_dn.html)

### 🔗 In-Chain Matching for OpenLDAP

A new OpenLDAP contrib overlay, **`inchain`**, implementing Microsoft’s **LDAP_MATCHING_RULE_IN_CHAIN** (OID `1.2.840.113556.1.4.1941`) for recursive matching across LDAP Distinguished Name references.

- [→ View our OpenLDAP overlay prototype on GitHub](https://github.com/univention/openldap/pull/1)
- [→ OpenLDAP Issue 9402: Add support for `LDAP_MATCHING_RULE_IN_CHAIN`](https://bugs.openldap.org/show_bug.cgi?id=9402)

### 🛡️ Working with OpenLDAP Set ACLs

A practical article about OpenLDAP set-based ACLs.

[→ Read the article](https://areq.gitlab.io/posts/2021-05-16-openldap-set-acls/)

### 🔐 OpenLDAP Add Content ACLs & DIT Content Rules

References for the LDAP ACL quiz and the somewhat surprising behavior of Add operations.

- [→ `slapd.conf(5)` - `add_content_acl`](https://man7.org/linux/man-pages/man5/slapd.conf.5.html)
- [→ `slapd.access(5)` - ACL requirements for Add operations](https://man7.org/linux/man-pages/man5/slapd.access.5.html)
- [→ OpenLDAP FAQ: DIT Content Rules](https://www.openldap.org/faq/data/cache/1473.html)

### 🐛 Misc linked issues

- [ITS 9795 - Remove memberof overlay](https://bugs.openldap.org/show_bug.cgi?id=9795#c1)
- [Issue #257: `ldap.dn.dn2str()` does not support flags](https://github.com/python-ldap/python-ldap/issues/257)
- [PR #466: feat(ldap.dn): Add support for different formats in `ldap.dn2str()` via flags](https://github.com/python-ldap/python-ldap/pull/466)

### 👤 Contact details

- 📧 `best` + `@` + `univention.de`
- https://github.com/spaceone/

### 💼 Career at Univention

Interested in open source, identity management, and digital sovereignty?

[→ Your next job might be at Univention](https://www.univention.com/about-us/careers/)
