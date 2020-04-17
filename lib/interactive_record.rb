require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    db[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "insert into #{table_name_for_insert} (#{col_names_for_insert}) values (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("select last_insert_rowid() from #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name_for_insert














end
