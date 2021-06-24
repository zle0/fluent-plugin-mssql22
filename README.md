# fluent-plugin-mssql22

[![Gem Version](https://img.shields.io/gem/v/fluent-plugin-mssql22.svg)](https://rubygems.org/gems/fluent-plugin-mssql22) 

## Installation

### RubyGems

```
gem install tiny_tds connection_pool fluent-plugin-mssql22
```

### Bundler

Add following line to your Gemfile:

```ruby
gem 'fluent-plugin-mssql22'
gem 'tiny_tds'
gem 'connection_pool'

```

And then execute:

```
bundle
```

## Configuration
- query : A single SQL statement using placeholder (*?{key}*)
- poolsize : 
- session_options : Session SET options separated by semicolons (;)

#### TinyTds Configuration
* username 
* password  
* host 
* port  
* database 
* timeout
* login_timeout
* #dataserver (..next version)   

## Example
```
<match metric.**>
  @type mssql22
  username "put"
  password "put!@#$"
  host "192.168.100.185"
  port 14434
  database "Metrics"
  query "EXEC USP_AddMetrics @Name='?{name}',@Data='?{data}';"
  poolsize 20
  session_options "SET ANSI_NULLS ON;SET ANSI_PADDING ON;SET ANSI_WARNINGS ON;SET ARITHABORT ON;"
  timeout 10
  login_timeout 10

  <buffer>
    @type memory
    total_limit_size 1024GB
    flush_interval 1s
    flush_at_shutdown true
    flush_thread_count 20
    retry_forever true
  </buffer>
</match>
```


