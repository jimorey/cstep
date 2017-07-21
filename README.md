# CSTEP: Casual Staff Time Entry Project

## Description

CSTEP was developed late 2016 for a department at UWA (The University of Western Australia), as a paperless alternative to their current timesheet system. That is to say it is an application for logging and approving hours worked by staff members so their pay can be calculated more easily.

It is of my current knowledge that the system is currently being used at UWA and continually developed in-house there, as was part of the contract.

The CSTEP system involves many roles:
* Generic Staff member
* Manager (Approver)
  * Note: Managers can be of various types.
* Account Staff member

The system was designed so that each role has access to different parts of the application required to fulfill their job. For example a **Generic Staff Member** cannot access the **Approver** section of the application as this would allow them to approve their own hours.

This version of CSTEP has relaxed restrictions on user roles because:
* This makes developing for the software a lot easier. Having to constantly log in and out of accounts to check functionality is tiresome.
* It allows new users to get a feel for the overall application as they are able to navigate through the entire system.

### Try CSTEP!

The development version can be accessed here: https://cstep.herokuapp.com/

Note: The site may take a few seconds to load upon the initial visit as Heroku servers are designed to sleep after a short period of time. This means if no one has accessed the site for a while the server will take a bit of time to wake-up and respond to the request.

Try any of these logins (role). Case sensitive:
* jim (Manager: ELICOS)
* tyler (Generic Staff Member)
* hugh (Generic Staff Member)
* alfred (Manager: Study Tours)
* sahan (Manager: Bridging Course)
* craig (Accounts Staff Member)

All **passwords** are **1234**

## Installation

**Requirements: Ruby!**

In the shell run the following commands:
```
gem install bundler
```
```
bundle install
```
```
ruby main.rb
```
Visit 'http://localhost:4567'

## Authors

Jim Reynolds

Craig Duncan

Tyler Smith

Sahan Nawaratna

## License

The CSTEP application by the above authors is licensed under a Creative Commons Attribution 3.0 [License](LICENSE.md).

A [human readable summary](https://creativecommons.org/licenses/by-nc/3.0/au/) of the license.
