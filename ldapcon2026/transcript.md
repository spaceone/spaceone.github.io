---
layout: default
title: Univention @ LDAPCon 2026 transcript
description: Transscript of my LDAPCon 2026 talk
---
# Tales from integrating OpenLDAP with the modern world

I'm not a musician, but I liked your performance! You can find all the material
I'm presenting here through this link.

My name is Florian Best, and I work for Univention. Today I brought a few
stories from our experience integrating OpenLDAP, and LDAP in general, over the
last 25 years of our company's history.

## Univention Nubus

Here you see an ArchiMate architecture diagram of our software. This is our
product, Univention Nubus.

We can deploy it on on-premises systems, such as Univention Corporate Server,
or we have Nubus for Kubernetes deployments. The systems differ a little, but
they share the same core Nubus product.

With UCS, we have our own Listener/Notifier system, which replicates changes to
other domain controllers. On Kubernetes, this is done through LDAP-native
`syncrepl`.

Our product is extensible through applications. Third-party software can easily
integrate with it: groupware such as Open-Xchange, file sharing such as
Nextcloud, RADIUS for Wi-Fi access, and many other applications. They can
integrate directly with OpenLDAP, using accounts and binds, or they can use our
provisioning system.

The provisioning system is based on NATS messaging. Events are put into queues,
and applications can subscribe to them. Or they can use the more modern
approach, Keycloak, the identity provider for OpenID Connect and SAML. That's
another way to integrate.

We also have a work-in-progress component called Guardian, which is intended to
centralize authorization decisions.

But at the core of all this, of course, is OpenLDAP.

## OpenLDAP rocks!

OpenLDAP really rocks. It is rock solid! We've been using it since 2002, longer
than it has been declared stable.

Since we migrated the backend to LMDB, we haven't had general raw-performance
problems or robustness problems with that backend anymore. We are really big
fans of LMDB. I'm a big fan. Maybe I should get a T-shirt.

I will ask a smart question later, I promise!

We also have Active Directory functionality through Samba 4 since 2011, and
Samba 4 uses LMDB as its backend as well. That works reliably, even for large
customers.

We can also integrate with Microsoft Active Directory. There are some
differences, of course, but we have connectors that synchronize the directory
contents between Samba and OpenLDAP in both directions. And the best thing is
that we provide an AD Takeover for migrations.

For this talk, I will focus on OpenLDAP and the layer we've built on top of it:
Univention Directory Manager, its REST API, and our web-based management
interfaces.

# Login required!

First of all, let's log in to the web interface. How do we do that? Certainly
not with this SQL injection! We need an LDAP bind, but how do we do that with
modern OpenID Connect?

## crudeoauth - OAuth 2.0 authentication at OpenLDAP

For this, we developed `crudeoauth`. It is a SASL mechanism using OAuth 2.0
bearer tokens. With a JWT access token, you can authenticate at an LDAP server
or other SASL-compatible software, for example a mail server such as Dovecot.

It is free as in *bearer*, not as in *beer*. You should check it out on GitHub.

It was inspired by another project, `crudesaml`, which provides something
similar for SAML. You can check that one out too. It hasn't had commits for
about ten years, but it is pretty stable.  Both projects also provide a PAM
module.

Just one hour ago, we released a rewrite of `crudeoauth` in Rust. In C, you
have to remember to `free()`. Rust doesn't let you double-`free()`. And with
LMDB, you don't need to `free()` at all - you memory-map it.

Memory management is important for maintainability. Our previous underlying C
library for the OAuth token validation is no longer maintained, and I'm also a
big fan of fine-grained error reporting.  We are a Debian-based system, and the
available C libraries in Debian didn't provide the capabilities we needed. So
that was another primary reason to rewrite it in Rust.

Here you can see some configuration options.  The module selects a configured
token claim, such as `preferred_username`, and exposes it as the SASL
authentication identity, which LDAP can then map to the authorization identity.

# UMC modules

After logging in, you see an overview of our Univention Directory Manager
modules. We manage computers, DNS settings, DHCP, groups, the LDAP directory
tree, policies, the recycle bin, and many other things.

Let's open the users module.

# Users module

Here we can filter for certain user properties and see the users in this
domain. We have search capabilities, and we can do operations such as adding,
deleting, and moving users.

# User wine

When we open a user, for example the user Wilhelmine, or `wine`, we have
several tabs with lots of object properties - LDAP attributes, basically -
which are easy to manage.

## Univention Directory Manager (UDM)

This is really our most important goal: Univention Directory Manager should
make directory administration as simple as possible.

Which interfaces do we provide? Of course, there is this web UI, but we also
have a nice command-line client for administrators on their machines. And for
automation, we have an HTTP, so-called REST API. If you know what REST is, it's
an architectural style - but we take the buzzword anyway.

Basically, the core is a library written in Python. You could compare it with
an object-relational mapper, to some extent, but we don't hide all the LDAP
internals.

There are things missing from LDAP itself. For example, we have nice metadata:
help texts, labels, and descriptions that the LDAP schema doesn't provide. We
need to enrich that.

We also have to take care of referential integrity, for example references that
aren't DN-based, such as a DNS pointer record referring to a computer. We have
to ensure uniqueness, partly with OpenLDAP built-ins and partly ourselves. We
need locking, transactions, and rollback on failure.

We don't use the integrated OpenLDAP transaction support yet. Transactions are
bound to one LDAP connection, and our code caches and reuses LDAP connections
for many things. Supporting these transactions would require us to restructure
quite a lot.

UDM also does stricter value validation in some places than DIT Content
Rules/the constraint overlay module can express and provides possible values
for selection.  And, most importantly, customers and third-party applications
can extend it: they can add schema elements, integrate them, customize
behavior, or change the views.

## UDM user objects: LDAP schema made human

So what is a user object in UDM? We map LDAP attributes to UDM properties. LDAP
attribute names aren't necessarily user-friendly, so we try to make them more
understandable, for example `username` instead of `uid`.

Several LDAP attributes can also be mapped to one property. We combine several
LDAP schemas in one object. A user object is a representation of a regular
person, a POSIX user, a Kerberos user, a Samba user, and several other things
at the same time. We bundle all of that into a single UDM object type, for
example `users/user`.  This abstracts away those many object classes.  The
`inetOrgPerson` object class has a fax number, but still no birth date in 2026,
which is one reason for Univention-specific extensions.

We also have to synchronize related properties: multiple password hashes,
disabled and locked states, account expiration dates, timestamps, and so on.
To achieve that, we've patched many components: Heimdal, the Kerberos server;
Samba; and added OpenLDAP overlays, including `shadowbind`, Kerberos-related
password functionality, and `ppolicy`.  Our Active Directory and Samba 4
synchronization also has to deal with many of these details, especially
password hashes.

# Technical Challenges

So, are you ready for some technical challenges we face?

## Distinguished Names (DN) comparisons

We have two distinguished names here. Are they equal? Yes, they are! Attribute
names are case-insensitive.

We can also add whitespace around separators. If the schema and matching rules
allow it, we can write values in uppercase or use different capitalization.

Fortunately, all LDAP DNs are UTF-8. So you cannot have something like a JPEG
photo inside a DN.

We can also hex-escape values, and we must escape certain special characters
that have semantic meaning, such as a plus sign, which could separate multiple
values in an RDN.

Can you come up with more representations? What about attribute aliases? What
about OIDs, numeric OIDs?

And with some matching rules, multiple consecutive spaces can be normalized to
one.

It's good that LDAPv2 no longer exists. There you could also have quotes!

Has anybody here ever had problems with this? We certainly have.  For me, the
important lesson is that the single source of truth is the LDAP server.  You
cannot reliably compare distinguished names just by comparing their string
representations.

You could try downloading the schema and implementing all the matching rules
yourself.  But we'll see later that this is not a very good idea, especially in
a security context.  It isn't like comparing URIs. I've written a bit more
about this; you can check out the link.

## User-supplied DNs: to compare or not to compare?

So what possible errors can we get here? I have two scenarios.

Administrators may copy and paste DNs from Active Directory or Windows, with
strange characters, or they may simply type something differently.  Then an
operation might fail. That's bad, but perhaps not a disaster.

Now imagine our Samba 4 Connector. It runs automatically. What happens if an
entire modification fails because one DN is represented differently? Maybe
multiple attributes are modified at once, and none of them can be synchronized.
That can really block things.

I have two incomplete ways of handling this. Either I compare the values
myself, but my comparison could disagree with OpenLDAP, or I pass the values
through unchanged and let OpenLDAP decide, which can fail for other reasons.
Neither approach really solves the problem.

## Offer possible choices for group memberships in a Web UI

Here's a nasty version of the same problem in a user interface.

Imagine we have this group, `users office Tübingen`, with some existing group
members. The stored members come directly from the `uniqueMember` attribute in
OpenLDAP.

Then we have a selection dialog in which we want to add or remove users. Its
choices come from a regular LDAP search. And maybe Python LDAP code normalizes
those DNs as well, changing their string representation yet again.

Now you may be unable to add or remove something, and in the worst case you
silently drop an existing group membership because of a mismatch in JavaScript
or the HTML `<select>` options.

That's a real problem. OpenLDAP normalizes `uniqueMember` in one way, including
aspects of schema-aware normalization, but not every part of the string
representation. And `python-ldap` normalization can differ from OpenLDAP
normalization.

And yes, customers really use special characters such as `+` in OU names.

## Towards reliable DN comparison

So what can we do about it? As I said, we shouldn't reimplement the complete
LDAP schema locally. I mean, I have a project where I'm doing some of that, and
the Apache project does it too. It can help, but it isn't the ultimate
solution.

Another approach would be the LDAP `compare` operation, but that compares
values against existing entries. It isn't a general way to compare two
arbitrary DN strings; you'd have to work against entries in the tree.

What is definitely not a solution is splitting one operation into several
operations. That only fixes some symptoms.

A pragmatic approach is to expose the normalization functionality from
`libldap` through `python-ldap`.  libldap's DN-to-string functionality provides
*syntax normalization*, but not schema-aware comparison using matching rules.
I submitted a pull request for that, and it's now included in `python-ldap`
3.5. At the time of the talk, that release was still upcoming.

My preferred solution would be an extended operation for LDAP DN comparisons. I
could imagine something like a `compare_dn` function implemented as an OpenLDAP
overlay. Maybe it could also provide special operations for comparing lists or
DN intersections.

Of course, asking the server for every comparison wouldn't scale, so we could
first do a cheap local comparison and only call the server when necessary.
That's just one idea for solving the problem.

# Recycle Bin

We're all human. We make mistakes. We delete an object, and sometimes we delete
a whole LDAP directory subtree, such as an organizational unit. And then we need
to restore it.

So we implemented a recycle bin. I asked myself: how much of this can we
implement using OpenLDAP's built-in functionality?

## Recycle Bin: Implementable with built-in OpenLDAP features?

First, we need to modify the deleted object so that it can't be used anymore.
We deactivate it by removing all its original object classes. It won't be found
as the original object anymore. There is an object class called
`extensibleObject` that lets us keep the LDAP attributes.

Then we use a stable unique identifier as the relative DN, which makes it
easier for us to handle. We move the object into another database, the
`cn=recyclebin` database.

There is also the DDS overlay, which lets an object expire and be removed
automatically after, for example, 90 days. Very nice.

The hardest part is keeping the references. I implemented a reference
attribute, and I can't remember the exact format from memory. I have to read
this line from the slide:

> Restore the deleted object's DN into the property `users` of the
> `groups/group` object identified by UUID "…".

Using a UUID means that the original group can be renamed or moved between
deleting the user and restoring it.

## Recycle Bin: Security aspects

There are security challenges too. We have multiple domain controllers and
organizational unit administrators who manage only a subtree. Of course, they
must be allowed to delete certain objects, but they must not be able to write
arbitrary data into the recycle-bin database, including those references.

If we allowed that, an administrator could say, "This user is also part of the
Domain Admins group." After restoring that user, he would be a domain
administrator.

That's why we implemented this asynchronously with a Listener plugin. That has
downsides of its own - like stale caches -, but at least those writes and the
collection of references aren't performed under the original user's LDAP
permissions; they're done by the privileged process.

The same problem applies to writing directly to the recycle bin.

My ideal solution would be to move this asynchronous handling into the OpenLDAP
server and make it synchronous. We could have an LDAP Control on delete, where
you say: move this entry into the recycle bin with this given retention-time.
The normal permissions to delete the object would apply, while OpenLDAP itself
would do the internal work.

For restore, I could imagine an extended operation or control that restores the
entry in a similar way, optinally with a target DN. With OpenLDAP 2.7, I
imagine we could also have LDAP ACLs for extended operations. That would be
nice. We're still on OpenLDAP 2.5; in our next minor UCS release we'll move to
2.6.

# Performance

Okay, I think I need to hurry up a little. Let's look at some performance
topics.

It's commonly known that OpenLDAP is the fastest and most efficient directory
software in the world. So we tried to challenge that a little!

## Performance: Virtual List View Benchmark

For one use case, we wanted to implement pagination in our UDM REST API, but
also in the web interfaces. I've had pull requests around this for five or seven
years, and I couldn't really get the configuration right. I thought maybe the
limits were wrong or something similar.

We made some benchmarks. When we measured it in a large environment, we could
actually make OpenLDAP run out of memory with paged searches and a small page
size. The next two weeks I asked myself: is OpenLDAP really that fast?

[PAUSE]

Luckily, the problem was in the Python LDAP client library. The context ID from
the VLV control wasn't passed from the previous response to the next request.
That means every new request started a completely new search and loaded another
result set into memory.

We fixed that. The fix is included in the latest `python-ldap` release. And now
we can say again: yes, OpenLDAP is the fastest thing on earth!

## Performance: Virtual List View & Simple Paged Results

We measured Simple Paged Results and Virtual List View. The performance is
actually quite close to a normal search. But we have other problems integrating
them.

For example, VLV is bound to the LDAP connection. Our multiprocessing service
requires stateless communication: but the Linux kernel distributes incoming
requests among the worker processes, which may use different LDAP connections.
We cannot use connection-bound pagination state in that architecture.

Also, you can cause denial of service with certain requests. How do you
configure the right limits for a generic solution? Some customers have 50
objects, others have hundreds or multiple thousands. That's really
difficult.

Simple Paged Results has other problems. It doesn't provide a total count,
proper backwards navigation or directly skipping pages. In some cases we don't
need that, but for web user interfaces we do.

More importantly, it doesn't survive a `slapd` restart properly. I could
trigger an endless loop because, as a client, you cannot reliably detect
whether the paging cookie is still valid.

And I'm also unsure about using it in our provisioning system. What happens
when objects are added between pages? We have to be sure that the process is
robust and complete.

## Performance: `memberOf` vs. `dynlist` (in an XL environment)

Next, let's look at group memberships. OpenLDPA provides the `dynlist` overlay,
which computes a virtual attribute during a read. It can provide similar
functionality to `memberOf`.

`memberOf` takes a different approach: when a group is written, it updates the
membership information. On reads, that information is already precomputed.

We benchmarked this in a very large environment. With `dynlist`, calculating
the member-of values took about 12 seconds without nested groups and 21 seconds
with nested groups. For a read-optimized database, it makes more sense to
compute these values at write time.

And retrieving the stored `memberOf` values took nearly 250 milliseconds.

For nested groups, I learned today that there's a new overlay. But it isn't
really suitable for us either, because the computed operational attribute is
always present when you request it. We would like to make that decision on the
client side.

So we have another approach: Microsoft's `LDAP_MATCHING_RULE_IN_CHAIN`. We have
a prototype implementation. Somebody else also requested it, and you can check
out the pull request in our OpenLDAP repository.

OpenLDAP 2.7 had at one point been close to dropping the `memberof` overlay.
And what I really wanted to say: thank you, for keeping the `memberOf`
overlay in OpenLDAP!

## Performance: LDAP ACL configuration for distributed OU structures

LDAP ACLs also have a performance impact. I have two examples.

We experimented with a multi-tenant project. We managed to destroy read
performance just by adding a few write-specific LDAP ACLs. That's because
`write` includes `read`, so the ACL engine also has to evaluate those rules for
reading.

But we have an even more complex product: UCS@school. This is the most complex
ACL configuration we have. It contains around 80 `access to` blocks, with
complex DN regex target matching, capture groups, and set ACLs using LDAP URIs.

Let's take a quick look.

## Our LDAP ACLs look like this (page 1)

These are some of our ACLs. That's page one. Do you want to see page two?

## ACL performance: some constructs are dramatically more expensive

We found a small pattern, and one of my colleagues analyzed the performance of
different ACL constructs in a large environment. There are some interesting
findings. This is only the beginning: we're still working on it, and I got some
additional results just yesterday.

Let me explain a few things. Our baseline is `dn.children`. That's 1 times.

If you use a `dn.regex` without capture groups, it's about seven times slower.
If you use captures, it's about eighteen times slower.

More important for us are the `by` clauses. Those can be much more expensive.
Normal group memberships are nice because OpenLDAP caches these checks. But set
ACLs aren't cached in the same way.

With a dereference in a set ACL, we measured around 23 times the baseline cost.
With additional dereferences and more complex expressions, the cost increases
further. Adding LDAP URIs can make it more than 50 times as expensive.

If you use set ACLs, I really recommend reading the article linked on this
slide. It contains many details.

There's also a structural problem in our LDAP ACLs. We often need `by * +0
break`, because we have an extensible ACL stack and third-party applications
need to insert rules. This is really hard to manage - maybe our biggest pain
point with LDAP ACLs.

What I would like to propose is doing it the other way around: starting with
`access by` and then describing all the targets.

# Critical security implications

It's getting a little hot here. And the really hot stuff is security! Let's
have some more fun with LDAP ACLs.

## LDAP ACLs Quiz: will this `add` operation succeed?

I've prepared a quiz. Here we have an ACL that grants write access for a
certain subtree, filtered by the `device` object class. It allows writing
`entry` and `@device`, meaning all attributes defined by that object class.

Now, using the account covered by this rule, we want to add this LDIF. But the
object doesn't have the `device` object class. It has a `shadowAccount`, with
root permissions.

Who thinks this `ldapadd` will fail?

Oh, nobody. Why not? Who thinks it will succeed? Also nobody?

<!--
An attendee apparently suggested a subclass relationship;
the speaker answered, "No, it's not a subclass."
-->

One thing you might imagine is that the filter cannot match a non-existing
entry, right? I thought someone would bring that up. But for this operation,
that's not the deciding factor: the filter is ignored here.

The answer depends on a configuration option: `add_content_acl`.

## enable `add_content_acl on`

That option is disabled by default. Maybe that should change in OpenLDAP 2.7 or
2.8 - I'm not sure. It controls whether an Add operation performs the relevant
ACL checks against the content being added.

You should really check your configuration if you work with LDAP ACLs. And
while you're at it, have a look at DIT Content Rules, which can restrict
combinations of object classes.

Okay, nobody is running out of the room. Your ACLs are all fine. Nice!

## Example LDAP ACL which restricts access to add only the objectClass `inetOrgPerson`

I have another example of why this gets complicated.

Imagine a role-based system with two auxiliary object classes,
`schoolAdministrator` and `schoolTeacher`. You are a teacher, and there is a
self-service application that allows you to modify your own entry - for
example, the attributes of `inetOrgPerson`.

This ACL would be vulnerable because allowing writes to `objectClass` also
allows arbitrary object-class values. You could add `schoolAdministrator` to
your own entry and make yourself a school administrator.

To make it correct, you need multiple clauses. First, a value-based rule that
only allows adding `inetOrgPerson`. Then another clause to prevent adding other
object-class values, followed by the permissions needed for the remaining
attributes.

Or, if it's possible, you could use DIT Content Rules to restrict object-class
combinations - but that isn't always possible.

## Centralizing authorization: Delegative administration

So LDAP ACLs are very complex. They're performance-critical and
security-critical.

We also have different authorization mechanisms across our whole stack, not
just LDAP ACLs. Customers are sometimes confused by UDM property names versus
LDAP attribute names, and every service has different configuration mechanisms
for it's authorization.

We're therefore working to centralize authorization decisions, so
administrators can configure policies using one unified concept. Applications
then have to make the authorization decisions themselves. They use privileged
accounts or service accounts for the underlying LDAP operations, but the
application has to decide what it actually grants.

## UDM delegative administration: Inventing our own policy language

I invented a language for this. You can see that I changed the direction from
`access to` to `access by`. That order fits better with what I want to express.

It's role-based. We grant access to certain object classes within a subtree,
and that subtree can come from a context. Then we grant actions such as
`search`, `read`, `modify`, `rename`, and so on.

We can control access to individual properties. Normal properties can be
writable. Some password or password-hash properties should be `writeonly`: you
can set them, but not read their contents.

You must not be allowed to write arbitrary roles, because then you could give
yourself super-admin permissions.

Everything else may be writable, but for a user's groups we need a special
constraint. Here is a CEL expression that checks whether `Domain Admins` is in
the list you want to set.

What do you think about this?

## Developer pain: Comparing DNs

Yes, here we are again: DN comparisons!

A deny-list based on an unreliable DN string comparison is dangerous.
If you just represent that DN in a different way you can bypass the check.
It's still the same DN, but the string representation differs.

That means for us, when protecting sensitive group memberships, we can only
work safely with an allow-list: permit only explicitly allowed DN values rather
than trying to deny a few forbidden string spellings.

## TL;DR: My personal LDAP extension proposals

So, that brings us to the end of the stories I wanted to tell today. I wanted
to go through all my extension proposals for OpenLDAP, but we don't have the
time. These topics are only a selection from roughly 15 years of working with
LDAP-based systems. Some ideas are concrete, some are more futuristic, and
some are simply things that have annoyed mefor years.

Maybe just one futuristic thing: it would be nice to have a JSON syntax. There
was someone talking about configuration here, and I would also like to do some
configuration directly in the directory tree, with matching rules similar to
what SQLite can do. And there's a lot more; I've already mentioned
some of it.
If any of them sound interesting, I would be very happy to discuss them afterwards.

## Time for discussion...

So, let's have some time for discussion.

Thank you very much for listening. Thank you very much to Symas for providing
OpenLDAP, and thank you for allowing me to speak here.

By the way, if you are interested in solving some of these LDAP problems with
us, we are hiring at Univention.  Just apply or contact me if you need a new
job and really want to solve deep LDAP problems.

The QR code links to an overview of all the references and links.
Thank you!
