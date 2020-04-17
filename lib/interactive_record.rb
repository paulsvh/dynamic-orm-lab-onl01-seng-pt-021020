require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
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
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "select * from #{self.table_name} where name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute = {})
    column = nil
    value = nil
    attribute.each do |k, v|
      column = k.to_s.downcase
      value = v
    end
    sql = "select * from #{table_name} where #{column} = '#{value}'"
    DB[:conn].execute(sql)
  end

end
