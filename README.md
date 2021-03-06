Bootstrap
=========

[![Build Status](https://travis-ci.org/dochang/ansible-role-bootstrap.svg?branch=master)](https://travis-ci.org/dochang/ansible-role-bootstrap)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-dochang.bootstrap-blue.svg)](https://galaxy.ansible.com/dochang/bootstrap/)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/dochang/ansible-role-bootstrap.svg)](http://isitmaintained.com/project/dochang/ansible-role-bootstrap "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/dochang/ansible-role-bootstrap.svg)](http://isitmaintained.com/project/dochang/ansible-role-bootstrap "Percentage of issues still open")

An ansible role to install Python on GNU/Linux machine.

The version of Python to be installed depends on the distribution of the target machine.

Since this role supports Python 3, Ansible 2.2+ is required.

Requirements
------------

None

Role Variables
--------------

None

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
        - { role: dochang.bootstrap }

License
-------

MIT

Author Information
------------------

Desmond O. Chang <dochang@gmail.com>
