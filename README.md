Bootstrap
=========

[![Build Status](https://travis-ci.org/dochang/ansible-role-bootstrap.svg?branch=master)](https://travis-ci.org/dochang/ansible-role-bootstrap)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-dochang.bootstrap-blue.svg)](https://galaxy.ansible.com/list#/roles/1847)
[![Issue Stats](http://issuestats.com/github/dochang/ansible-role-bootstrap/badge/pr)](http://www.issuestats.com/github/dochang/ansible-role-bootstrap)
[![Issue Stats](http://issuestats.com/github/dochang/ansible-role-bootstrap/badge/issue)](http://www.issuestats.com/github/dochang/ansible-role-bootstrap)

An ansible role to install `python2` and `lsb_release` on GNU/Linux machine.

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
