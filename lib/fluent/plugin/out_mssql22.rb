require 'fluent/plugin/output'
require 'tiny_tds'
require 'connection_pool'

class Mssql22Output < Fluent::BufferedOutput
  Fluent::Plugin.register_output('mssql22', self)

  include Fluent::SetTimeKeyMixin
  include Fluent::SetTagKeyMixin

  config_param :username, :string
  config_param :password, :string
  config_param :host, :string
  config_param :port, :integer
  config_param :database, :string
  config_param :query, :string
  config_param :poolsize, :integer, default: 10
  config_param :timeout, :integer, default: 60
  config_param :login_timeout, :integer, default: 10
  config_param :session_options, :string, default: nil

  def configure(conf)
    super
    @keys = @query.scan(/\?\{(.*?)\}/).flatten
    @format_proc = Proc.new{|tag, time, record| @keys.map{|k| [k,record[k]]}.to_h}
    
    unless @session_options.nil? 
      @session_sets = @session_options.split(';')
    end

  end

  def format(tag, time, record)
    [tag, time, @format_proc.call(tag, time, record)].to_msgpack
  end

  def client
    begin
      pool = ConnectionPool.new(size: @poolsize) {
        client = TinyTds::Client.new(
          username: @username,
          password: @password,
          host: @host,
          port: @port,
          database: @database,
          appname: 'fluentd-tinytds',
          timeout: @timeout,
          login_timeout: @login_timeout
        )
        
        unless @session_sets.nil? 
          @session_sets.each do |set|
            client.execute(set).do
          end
        end
 
        client
      }
	  
    rescue Exception => e
      raise Fluent::ConfigError, e.message
    end

    pool
  end

  def start
    super
    @cp = client
  end

  def stop
    super
  end

  def query_bind(data)
    query = @query
    data.map do |k,v|
      query = query.gsub("?{#{k}}",v.to_s.gsub(/'/,"''"))
      
    end
    query
  end
 
  def write(chunk)
    begin
      @cp.with { |c| c.execute('select 1;').do }
    rescue
      @cp = client
    end

    chunk.msgpack_each do |tag, time, data|
      @cp.with {|c| c.execute( query_bind(data) ).do}
    end
  end

end
