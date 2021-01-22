require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
      end


    def self.column_names
        sql = "pragma table_info('#{table_name}')"
        DB[:conn].execute(sql).map do |column_hash|
            column_hash["name"]
        end 
    end 
  
    def initialize(attribute = {})
        attribute.each do |k, v|
            self.send("#{k}=", v)
        end 
    end 

    def table_name_for_insert
        self.class.table_name
    end 

    def col_names_for_insert
        self.class.column_names.delete_if {|name| name == "id"}.join(", ")
    end 

    def values_for_insert
        self.col_names_for_insert.split(", ").map do |col_name|
            "'#{self.send(col_name)}'"
        end.join(", ")
    end 

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", [name]) 
    end 
    # name = "Jan"

    def self.find_by(attribute)
        attr_value = attribute.values.first
        data_type = attr_value.class == Fixnum ? attr_value : "'#{attr_value}'"
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first} = #{data_type}")
        # binding.pry 
    end 
end
        
