# Full text searching plugin for Redmine

*This version is under heavy development, and a lot of stuff is not working yet*

[![Build Status](https://travis-ci.org/Undev/redmine_elasticsearch.png?branch=master)](https://travis-ci.org/Undev/redmine_elasticsearch)
[![Code Climate](https://codeclimate.com/github/Undev/redmine_elasticsearch.png)](https://codeclimate.com/github/Undev/redmine_elasticsearch)

This plugin integrates elasticsearch into Redmine


## Description

todo

You can add additional index options to config/additional_environment.rb.
For example:

    config.additional_index_properties = {
        :issues => {
            :issue_tags => {
                :properties => {
                    :name => { :type => 'string' }
                }
            },
            :tags => { :type => 'string' }

        }
    }

All this options will be joined to index settings.

## Install

1. Copy plugin directory into REDMINE_ROOT/plugins.
If you are downloading the plugin directly from GitHub,
you can do so by changing into your REDMINE_ROOT directory and issuing a command like

        git clone https://github.com/Undev/redmine_elasticsearch.git plugins/redmine_elasticsearch

2. Restart Redmine

## Links

- http://www.redmine.org/
- http://www.elasticsearch.org/

## License

Copyright (C) 2014 Undev.ru

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
