# Redmine Elasticsearch Plugin

[![Build Status](https://travis-ci.org/Restream/redmine_elasticsearch.svg?branch=master)](https://travis-ci.org/Restream/redmine_elasticsearch)
[![Code Climate](https://codeclimate.com/github/Restream/redmine_elasticsearch/badges/gpa.svg)](https://codeclimate.com/github/Restream/redmine_elasticsearch)

This plugin integrates the Elasticsearch<sup>®</sup> full-text search engine into Redmine.

Elasticsearch is a trademark of Elasticsearch BV, registered in the U.S. and in other countries.

## Compatibility

This plugin version is compatible only with Redmine 3.x and later.
All tests are performed with Elasticsearch 5 version. 
Work with other versions of Elasticsearch is possible but not guarantied.

## Installation

1. This plugin requires [Redmine Resque Plugin](https://github.com/Restream/redmine_resque). Install the plugin, but do not start a Resque worker for now.

2. Download and install [Elasticsearch](http://www.elasticsearch.org/overview/elkdownloads/).

3. Install other required plugins:

    * [Morphological Analysis Plugin for ElasticSearch](https://github.com/imotov/elasticsearch-analysis-morphology)

    * [Mapper Attachments Type for Elasticsearch](https://github.com/elasticsearch/elasticsearch-mapper-attachments)

4. To install Redmine Elasticsearch Plugin,

    * Download the .ZIP archive, extract files and copy the plugin directory into #{REDMINE_ROOT}/plugins.
    
    Or

    * Change you current directory to your Redmine root directory:  

            cd {REDMINE_ROOT}
            
      Copy the plugin from GitHub using the following commands:
      
            git clone https://github.com/Restream/redmine_elasticsearch.git plugins/redmine_elasticsearch

5. Install the required gems:

        bundle install

6. Reindex all documents using the following command:

        cd {REDMINE_ROOT}
        bundle exec rake redmine_elasticsearch:reindex_all RAILS_ENV=production

7. Start a Resque worker (as described in [Redmine Resque Plugin](https://github.com/Restream/redmine_resque) installation instructions).

        cd YOUR_REDMINE_ROOT
        bundle exec rake resque:work RAILS_ENV=production QUEUE=*

8. Restart Redmine

Now you should be able to see the plugin in **Administration > Plugins**. 

## Configuration

By default, only regular fields are indexed. To index custom fields, you should add them to **config/additional_environment.rb**. For example, to enable indexing of issue tags, add the following code:

    config.additional_index_properties = {
        issues:  {
            tags:  { type:  'string' }
        }
    }

For change connection options just add some to config/configuration.yml. Here an example:

    default:
      elasticsearch:
        log: true
        request_timeout: 180
        host: '127.0.0.1'
        port: 9200

[Full list of available options.](https://github.com/elastic/elasticsearch-ruby/blob/master/elasticsearch-transport/lib/elasticsearch/transport/client.rb#L34)

## Usage

The plugin enables full-text search capabilities in Redmine.

Search is performed using a query string, which is parsed into a series of terms and operators. A term can be a single word (*another* or *issue*) or a phrase (*another issue*). Operators allow you to customize your search. 

For more information about the query string syntax, see [Elasticsearch Reference]( http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax).

The search results are counted and displayed according to the current user permissions.

You can search for one word by typing the word or its initial part in the **Search** box. If you type several words, the search results will show pages that contain at least one of these words. To search for all words, enable the **All words** check box. If you want to search for the exact phrase, surround it by double quotes (*"another issue"*).  
![search options](doc/elasticsearch_1.png)

By default, search is performed in the following fields:

* Subject or Title
* Description
* Custom fields values
* Notes (only for issues)

If you enable the **Search titles only** check box, search will be performed only in the **Subject** / **Title** field.

To perform search in other fields, you can specify the field name and its value in the query string in the following format: `field:value`.

The table below lists the fields that can be searched, and the corresponding Redmine field names. Alternative field names are preceded with a tilde ('~').

### Issues

| Query string field | Redmine field name |
|--------------------|------------------- |
| subject   ~ title | Subject |
| description | Description |
| author | Author |
| category | Category |
| created_on   ~ datetime | Created |
| updated_on | Updated |
| closed_on | Closed |
| due_date | Due date |
| assigned_to | Assignee |
| status | Status |
| priority | Priority |
| done_ratio | % Done |
| custom_field_values   ~ cfv | Custom fields |
| fixed_version   ~ version | Target version |
| is_private   ~ private | Private |
| is_closed   ~ closed | Issue closed |
| journals.notes | Notes |
| url | URL |

*Note that 'subject ~ title' means that you can use 'subject' or 'title' in a query*

For example this query will search issues with done_ratio from 0 to 50 and due_date before April 2015:

    done_ratio:[0 50] AND due_date:[* 2015-04]

### Projects

| Query string field | Redmine field name |
|--------------------|------------------- |
| name   ~ title | Name |
| description | Description |
| author | Author |
| created_on   ~ datetime | Created |
| updated_on | Updated |
| homepage | Homepage |
| due_date | Due date |
| url | URL |
| identifier | Identifier |
| custom_field_values   ~ cfv | Custom fields |
| is_public   ~ public | Public |

### Changesets

| Query string field | Redmine field name |
|--------------------|------------------- |
| title | Title |
| comments | Comment |
| committer   ~ author | Author |
| committed_on   ~ datetime | Created |
| url | URL |
| revision | Revision |

### News

| Query string field | Redmine field name |
|--------------------|------------------- |
| title | Title |
| description | Description |
| author | Author |
| created_on   ~ datetime | Created |
| url | URL |
| summary | Summary |
| comments_count | Comments |

### Messages

| Query string field | Redmine field name |
|--------------------|------------------- |
| subject   ~ title | Subject |
| content   ~ description | Content |
| author | Author |
| created_on   ~ datetime | Created |
| updated_on | Updated |
| replies_count | Replies|
| url | URL |

### Wiki pages

| Query string field | Redmine field name |
|--------------------|------------------- |
| title | Title |
| text   ~ description | Text |
| author | Author |
| created_on   ~ datetime | Created |
| updated_on | Updated |
| url | URL |

### Documents

| Query string field | Redmine field name |
|--------------------|------------------- |
| title | Title |
| description | Description |
| author | Author |
| created_on   ~ datetime | Created |
| url | URL |
| category | Category |

### Files

| Query string field | Redmine field name |
|--------------------|------------------- |
| attachments.created_on | Created |
| attachments.filename | Format |
| attachments.description | Description |
| attachments.author | Author |
| attachments.filesize | Size |
| attachments.digest | MD5 digest |
| attachments.downloads | D/L |
| attachments.file | Attachment content |

You can search for issues, projects, news, documents, wiki pages and messages by attachments. For example, to limit the search scope to containers with the **somefile.pdf** attachment filename, use the following syntax:

    attachments.filename:somefile.pdf

## Testing

    bundle exec rake redmine:plugins:test RAILS_ENV=test NAME=redmine_elasticsearch START_TEST_CLUSTER=true TEST_CLUSTER_COMMAND={PATH_TO_ELASTICSEARCH}

## Maintainers

Danil Tashkinov, [github.com/nodecarter](https://github.com/nodecarter)

## License

Copyright (c) 2017 Restream

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
