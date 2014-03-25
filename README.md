# Full text searching plugin for Redmine

[![Build Status](https://travis-ci.org/Undev/redmine_elasticsearch.png?branch=master)](https://travis-ci.org/Undev/redmine_elasticsearch)
[![Code Climate](https://codeclimate.com/github/Undev/redmine_elasticsearch.png)](https://codeclimate.com/github/Undev/redmine_elasticsearch)

This plugin integrates elasticsearch into Redmine

## Description

The query string is parsed into a series of terms and operators.
A term can be a single word *quick* or *brown* or a phrase, surrounded by double quotes *"quick brown"* 
which searches for all the words in the phrase, in the same order.
Operators allow you to customize the search. More detailed query syntax here: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html

Search and counting of results is made with regard to the rights of the current user.

Below is a list of fields that can be searched.

### Issues

* subject ~ title
* description
* author
* category
* created_on ~ datetime (for redmine 2.3.0 and higher)
* updated_on
* closed_on
* due_date
* assigned_to
* category
* status
* priority
* done_ratio
* custom_field_values
* fixed_version ~ version
* is_private ~ private
* is_closed ~ closed
* journals.notes

*'subject ~ title' means that you can use 'subject' or 'title' in query*

For example this query will search issues with done_ratio from 0 to 50 and due_date before april 2014:

    done_ratio:[0 50] AND due_date:[* 2014-04]

### Changesets

* committed_on ~ datetime
* title
* comments ~ description
* committer ~ author

### Documents

* created_on ~ datetime
* title
* description
* author
* category

### Forum messages

* created_on ~ datetime
* subject ~ title
* content ~ description
* author
* updated_on
* replies_count

### Projects

* created_on ~ datetime
* name ~ title
* description
* author
* updated_on
* homepage
* identifier
* custom_field_values
* is_public

### Wiki pages

* created_on ~ datetime
* title
* text ~ description
* author
* updated_on

### News

* created_on ~ datetime
* title
* description
* author
* summary
* comments_count

## Install

1. Download and install [Elasticsearch](http://www.elasticsearch.org/overview/elkdownloads/)

    Also you need to install [Morphological Analysis Plugin for ElasticSearch](https://github.com/imotov/elasticsearch-analysis-morphology)

    Check installation instructions on the plugin page:
    **https://github.com/imotov/elasticsearch-analysis-morphology#installation**

2. Install the required [redmine_resque](https://github.com/Undev/redmine_resque plugin)

        cd YOUR_REDMINE_ROOT
        git clone https://github.com/Undev/redmine_resque.git plugins/redmine_resque

3. Install this plugin

        cd YOUR_REDMINE_ROOT
        git clone https://github.com/Undev/redmine_elasticsearch.git plugins/redmine_elasticsearch

4. Install required gems

        bundle install

5. Reindex all documents with the following command

        cd YOUR_REDMINE_ROOT
        bundle exec rake redmine_elasticsearch:reindex_all RAILS_ENV=production

6. Start resque worker

        cd YOUR_REDMINE_ROOT
        bundle exec rake resque:work RAILS_ENV=production

7. Restart Redmine

## Configuration

You can add additional index options to config/additional_environment.rb.
For example:

    config.additional_index_properties = {
        :issues => {
            :tags => { :type => 'string' }
        }
    }

All this options will be joined to index settings.

You can explicit set elasticsearch node by setting ELASTICSEARCH_URL environment variable.

## Links

- http://www.redmine.org/
- https://github.com/karmi/retire
- http://www.elasticsearch.org/

## License

Copyright (C) 2014 Undev.ru

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
