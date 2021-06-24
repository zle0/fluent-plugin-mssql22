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
  config_param :port, :string
  config_param :database, :string
  config_param :sql, :string

  def configure(conf)
    super
    @keys = @sql.scan(/\?\{(.*?)\}/).flatten
    @format_proc = Proc.new{|tag, time, record| @keys.map{|k| [k,record[k]]}.to_h}
  end

  def format(tag, time, record)
    [tag, time, @format_proc.call(tag, time, record)].to_msgpack
  end

  def client
    begin
      pool = ConnectionPool.new(size: 100) {
        TinyTds::Client.new(
          username: @username,
          password: @password,
          host: @host,
          port: @port,
          database: @database,
          appname: 'fluentd - tinytds',
		  timeout: 60
        )
      }
	  
    rescue
      raise Fluent::ConfigError, "Cannot open database, check user or password"
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

  def sql_bind(data)
    sql = @sql
    data.map do |k,v|
      sql = sql.gsub("?{#{k}}",v.to_s.gsub(/'/,"''"))
      
    end
    sql
  end
 
  def write(chunk)
    begin
	  @cp.with { |c| c.execute('SELECT 1;').do }
	rescue
      @cp = client
    ensure
      @cp.with do |c|
        c.execute('SET ANSI_NULLS ON;').do
        c.execute('SET ANSI_PADDING ON;').do
        c.execute('SET ANSI_WARNINGS ON;').do
        c.execute('SET ARITHABORT ON;').do
        c.execute('SET CONCAT_NULL_YIELDS_NULL ON;').do
        c.execute('SET NUMERIC_ROUNDABORT ON;').do
        c.execute('SET QUOTED_IDENTIFIER ON;').do
        c.execute('SET NUMERIC_ROUNDABORT OFF;').do
	  end
    end

    chunk.msgpack_each do |tag, time, data|
      #p sql_bind(data)
      @cp.with {|c| c.execute( sql_bind(data) ).do}
    end
  end

end