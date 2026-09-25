### Welcome to my github profile.

I am an Open Source Software Enginner working for [Univention](https://github.com/univention/).

My special interests are [HTTP](http://tools.ietf.org/html/7230), [REST architecture](http://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm), [LDAP](https://datatracker.ietf.org/doc/html/rfc4511), Security technology, [Python](https://github.com/python/), protocols, generic libraries and Clean-Code - and I like to combine all of them.

#### Univention GmbH

At [Univention](https://github.com/univention/) I am working at the [Debian](https://www.debian.org/) based Linux Distribution [Univention Corporate Server](https://www.univention.com/).

My focus topics there are:
IAM (Identity and Access Management):
* OpenLDAP
* REST-Services for LDAP-objects
* Active Directory & Samba 4 to OpenLDAP connector
* A little bit Kerberos (Heimdal) and Samba 4

Web Interfaces & Design:
* Javascript (dojo toolkit, vue) web frontend
* HTMX based HTML frontends
* HTTP backends
* responsive Web-Design

Python:
* Python linting standards
* Python 2.7 to 3 migration

Security:
* Finding and fixing internal security issues

Containerization:
* building Docker containers for our currently Debian-packaged components

#### private stuff

##### security
In my spare time I used to do Hacking Challenges and penetation testing (e.g. at [WeChall](https://www.wechall.net/profile/space)).

##### FreeIAM LDAP Client library
[FreeIAM](https://docs.freeiam.org/en/latest/) - Currently just a LDAP Client library for Python, which is capable of all LDAP functionality in a developer-friendly API.
It has 100 % test coverage, 100 % mypy and ty compatible type annotations, async and sync support.
Supported LDAP functionality: TLS, SASL, pagination, extended DN handling (comparison, normalization), extended LDAP filter tree (parsing, handling and manipulation), all common LDAP controls, extended operations.

##### httoop
I am the inventor of [httoop](https://github.com/spaceone/httoop/),
an object oriented HTTP library
(for implementing HTTP servers, clients, caches and proxies)
focusing on strict compliance, security, object orientation,
simplicity in use, using strictly the vocabulary of HTTP instead of inventing own things
and not doing extra things and workarounds.
It's the best HTTP library I've seen in the Python world so far ;-).
As I am miserable in marketing, there are only a few users yet.

##### circuits
I am maintainer of [circuits](https://github.com/circuits/circuits).
Circuits is a **Lightweight** **Event** driven and **Asynchronous** **Application Framework** for the [Python Programming Language](http://www.python.org/) with a strong **Component** Architecture.
A project which exists long before *asyncio* - but nowadays isn't as modern as these frameworks - maybe we can catch up somewhen.


##### circuits.http

While `circuits` has a `circuits.web` component,
I created a different Implementation called [circuits.http](https://github.com/spaceone/circuits.http/)
using my [httoop](https://github.com/spaceone/httoop/) project as basis.
This focused on more explicit request routing and simplifies implementing all `HTTP` functionalities and `REST` principles.

#### configuration files
I am a heavy user of Linux, Python, git, vim, sway/i3-wm, ruff, ty.
My configration files are available as Debian package at [dotfiles](https://github.com/spaceone/dotfiles/).

# statistics
![spaceone GitHub stats](https://github-readme-stats.vercel.app/api?username=spaceone&show_icons=true)
