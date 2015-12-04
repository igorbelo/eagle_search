# EagleSearch
[![Code Climate](https://codeclimate.com/github/igorbelo/eagle_search/badges/gpa.svg)](https://codeclimate.com/github/igorbelo/eagle_search)

EagleSearch is a ruby gem that integrates Rails ActiveRecord to Elasticsearch.
It handles the Elasticsearch internals by itself, and in most cases minimal (none) configuration is needed.

## Installation
First of all, you should have Elasticsearch installed.

Using Homebrew:

```sh
brew install elasticsearch
```

Add `eagle_search` to Gemfile:

```ruby
gem 'eagle_search'
```

## Get Started
Add EagleSearch module and call `eagle_search` class method in your ActiveRecord:

```ruby
class Article < ActiveRecord::Base
  include EagleSearch
  eagle_search

  def index_data
    as_json only: [:title, :body, :active]
  end
end
```

Notice that EagleSearch will use the `#index_data` method to know what will be indexed.

As the model was configured, you should populate the records into Elasticsearch index:
```ruby
Article.reindex
```
EagleSearch will automatically handle the mapping based on model column types unless you explicit set a custom mapping.

```ruby
Article.search "programming language"
```

## Searching
### Basic
The following code will return all articles:
```ruby
articles = Article.search "*"
```

You can iterate over the records (will hit the database):
```ruby
articles.each do |article_record|
  ...
end
```

To avoid the database, you can access the hits directly:
```ruby
articles.hits.each do |article_hit|
  ...
end
```

### Filtering
Get only active articles:
```ruby
Article.search "*", filters: { active: true }
```

If you want to combine conditions, you should add the operator:
```ruby
Product.search "*", filters: {
  and: {
    active: true,
    in_stock: true
  }
}
```

You can go deep, mixing AND and OR operators:
```ruby
Product.search "*", filters: {
  and: {
    active: true,
    or: [
      {
        and: {
          price: { gte: 543.50 },
          available_stock: 300
        }
      },
      {
        available_stock: 500
      },
      {
        not: { expired: false }
      }
    ]
  }
}
```

Filtering by string (only for `not_analyzed` strings):
```ruby
Product.search "*", filters: {
  name: "Book: The Hidden Child"
}
```
If you want to map a string field as an exact value, you need to set it, as documented [here](https://github.com/igorbelo/eagle_search#exact-string-fields).

Filtering by ranges:
```ruby
Product.search "*", filters: {
  available_stock: (10..150)
}
```

or equivalent:
```ruby
Product.search "*", filters: {
  available_stock: {
    gte: 10,
    lte: 150
  }
}
```
Available options are `gte`, `gt`, `lt`, `lte`.

### Complex queries
As queries in some cases might to get very complex, you can make your query by yourself, in the next code, EagleSearch will replace ONLY the query part of [filtered query](https://www.elastic.co/guide/en/elasticsearch/reference/1.4/query-dsl-filtered-query.html), which will let you to use EagleSearch filter:
```ruby
Product.search "*", custom_query: {
  ...
}, filters: { price: { gt: 50 } }
```

Similarly, you can make the filter part by yourself:
```ruby
Product.search "*", custom_filter: {
  ...
}
```

If you need to make the whole query by yourself, set a custom payload:
```ruby
Product.search "*", custom_payload: {
  ...
}
```

### Relevance (boost)
If you want to consider some fields more important:
```ruby
Product.search "*", fields: ["name^5", "description"]
```
The number 5 is the factor that the field will be boosted, see [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#_literal_fields_literal_and_per_field_boosting).

### Pagination (tested with Kaminari)
```ruby
Product.search "*", page: 2, per_page: 20
```

Defaults:
`page`: 1 and `per_page`: 10

### Typoes and misspellings
```ruby
Product.search "neighhbour" #matches documents containing whether 'neighbor' or 'neighbour'
```

### Highlight
```ruby
products = Product.search "book", highlight: { fields: [:name], tags: ["<span>"] }
products.hits.each do |hit|
  hit["highlight"]["name"] # "<span>Book</span>: The Hidden Child"
end
```

### Autocomplete
```ruby
Product.search "fri" # will match docs with fields like: "fries, friendship..."
```
You can disable this behavior:
```ruby
Product.search "fri", autocomplete: false # won't match docs with fields like: "fries, friendship..."
```

### Aggregations
[Official documentation](https://www.elastic.co/guide/en/elasticsearch/reference/1.4/search-aggregations.html)

To aggregate data, set the aggregations option:
```ruby
products = Product.search "*", aggregations: :category
products.aggregations
```
Response:
```ruby
{
  "category"=>{
    ...
    "buckets"=>[
      { "key"=>"Book", "doc_count"=>2 },
      { "key"=>"Vesture", "doc_count"=>1 }
    ]
    ...
  }
}
```

By default, when an aggregation is a symbol or a string, it will be interpreted as a [terms aggregation](https://www.elastic.co/guide/en/elasticsearch/reference/1.4/search-aggregations-bucket-terms-aggregation.html).

Multiple aggregations:
```ruby
products = Product.search "*", aggregations: [:category, :country]
products.aggregations
```
Response:
```ruby
{
  "category"=>{
    ...
    "buckets"=>[
      { "key"=>"Book", "doc_count"=>2 },
      { "key"=>"Vesture", "doc_count"=>1 }
    ]
    ...
  },
  "country"=>{
    ...
    "buckets"=>[
      { "key"=>"Brazil", "doc_count"=>1 },
      { "key"=>"USA", "doc_count"=>1 },
      { "key"=>"Spain", "doc_count"=>1 }
    ]
    ...
  }
}
```

Nesting aggregations:
```ruby
products = Product.search "*", aggregations: { category: :country }
products.aggregations
```
Response:
```ruby
{
  "category"=>{
    ...
    "buckets"=>[
      {
        "key"=>"Book"
        "doc_count"=>2,
        "country"=>{
          "buckets"=>[
            { "key"=>"Brazil", "doc_count"=>1 },
            { "key"=>"USA", "doc_count"=>1 }
          ]
        }
      },
      {
        "key"=>"Vesture"
        "doc_count"=>1,
        "country"=>{
          "buckets"=>[
            { "key"=>"Spain", "doc_count"=>1 }
          ]
        }
      }
    ]
    ...
  }
}
```

Stats aggregations:
```ruby
products = Product.search "*", aggregations: {
  available_stock: { type: "stats" }
}
products.aggregations
```
Response:
```ruby
{
  "available_stock"=>{
    "count"=>4,
    "min"=>20.0,
    "max"=>400.0,
    "avg"=>185.0,
    "sum"=>740.0
  }
}
```

Mixing terms and stats aggregations:
```ruby
products = Product.search "*", aggregations: {
  country: {
    available_stock: { type: "stats" }
  }
}
products.aggregations
```
Response:
```ruby
{
  "country"=>{
    ...
    "buckets"=>[
      {
        "key"=>"Brazil",
        "doc_count"=>1,
        "available_stock"=>{
          "count"=>4,
          "min"=>20.0,
          "max"=>400.0,
          "avg"=>185.0,
          "sum"=>740.0
        }
      },
      ...
    ]
  }
}
```

Ranges aggregations:
```ruby
products = Product.search "*", aggregations: {
  available_stock: {
    ranges: [
      (0..30),
      (30..60),
      { from: 60, to: 90 },
      { from: 90 }
    ]
  }
}
products.aggregations
```
Response:
```ruby
{
  "available_stock"=>{
    ...
    "buckets"=>[
      {
        ...
        "key"=>"0-30",
        "doc_count"=>4
      },
      {
        ...
        "key"=>"30-60",
        "doc_count"=>2
      },
      {
        ...
        "key"=>"60-90",
        "doc_count"=>13
      },
      {
        ...
        "key"=>"90-*",
        "doc_count"=>37
      }
    ]
  }
}
```

Remember that you can go as deep as you want nesting and mixing terms and stats aggregations.

## Settings
### Exact string fields
By default, EagleSearch (even  Elasticsearch) will map string field as `analyzed`, which won't let you to filter these fields.

If you have an exact value for string, and want to search by its exact value, you explicitly need to declare it, for example:
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search exact_match_fields: [:code]
end
```

It will let you to filter string fields:
```ruby
Product.search "*", filters: {
  code: "JUR123-A"
}
```

### Unsearchable fields
You can disable the search and filter on certain fields:
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search unsearchable_fields: [:code]
end
```

### Synonyms
[Official documentation](https://www.elastic.co/guide/en/elasticsearch/reference/1.4/analysis-synonym-tokenfilter.html)

You can explicitly declare your synonyms in your class:
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search synonyms: [
    "dog, canine",
    "cup, glass, chalice"
  ]
end
```
So, whether searching by `cup`, `glass` or `chalice` will match documents containing these words, as well as `dog` or `canine`.

Putting synonyms in a separated file:
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search synonyms: {
    format: "wordnet", #could be solr format
    synonyms_path: "synonyms.txt" #relative to elasticsearch config location
  }
end
```

Using [WordNet format](http://wordnetcode.princeton.edu/3.0/) files:
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search synonyms: {
    format: "wordnet",
    synonyms_path: "[WORDNET_FILE_LOCATION]"
  }
end
```

Using Solr format files:
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search synonyms: {
    format: "solr",
    synonyms_path: "[SOLR_FILE_LOCATION]"
  }
end
```

### Custom Mapping
You can declare the [index mapping](https://www.elastic.co/guide/en/elasticsearch/guide/current/mapping-analysis.html) by yourself:
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search mappings: {
    type_name: {
      properties: {
        name: {
          index: "no",
          type: "string"
        }
      }
    }
  }
end
```

### Custom index name
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search index_name: "product"
end
```

### Language
You can set the language of your index (default is english):
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search language: "portuguese"
end
```
Available languages are [here](https://www.elastic.co/guide/en/elasticsearch/reference/1.4/analysis-lang-analyzer.html)

**IMPORTANT all of the settings above require index to be reindexed:**
```ruby
Product.reindex
```

### Auto reindex
As a record is created or changed, EagleSearch automatically reindex the record by default.

You can disable the auto reindex:
```ruby
class Product < ActiveRecord::Base
  include EagleSearch
  eagle_search reindex: false
end
```

## Roadmap
* Suggestions
* Elasticsearch 2.x
