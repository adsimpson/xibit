module Xibit
  
  class QueryBuilder
    
    attr_reader :klass, :params
    attr_accessor :conditions
    
    def initialize(klass, params)
      @klass = klass
      @params = params
      @conditions = []
    end
    
    def query_search(attrs)
      value = params[0]
      return nil if value.nil?
      
      attrs.each do |attr|
        attr_type = attribute_type attr
        sql = "#{attr} LIKE ?"
        add_condition(sql, "%#{value}%", 'or')
      end
      conditions.empty? ? nil : conditions
    end
    
    def attribute_search(attrs)
      attrs.each do |attr, default_value|
        value = params[attr]
        value = params[attr.to_s.pluralize] if value.nil?
        value = default_value if value.nil?
        unless value.nil?
          attr_type = attribute_type attr 
          values = value.to_s.split(',').map { |v| typecast_attribute_value v, attr_type }
          add_condition(build_sql(attr,values), values)
        end
      end
      conditions.empty? ? nil : conditions
    end
    
    def attribute_type(attr)
      return nil unless klass
      column = klass.columns_hash[attr.to_s]
      attr_type = column ? column.type  : nil
    end
    
    def typecast_attribute_value(value, attr_type)
      value = case attr_type
        when :datetime then value.to_datetime
        when :integer then value.to_i
        when :boolean then (value == 'true')
        else value
      end
    end
          
    def build_sql(attr, values)
      if values.count>1
        "#{attr} IN (?)"
      elsif values[0].is_a?(String) && values[0] =~ /\*/
        values[0].gsub! '*', '%'
        "#{attr} LIKE ?"
      else
        "#{attr} = ?"
      end
    end
          
    def add_condition(sql, values, conjunction='and')
      return unless (sql.is_a?(String) and sql.present?)
      conditions[0] = conditions.first.present? ? " #{conditions.first} #{conjunction.to_s.upcase} #{sql}  " : sql 
      conditions.push values  
    end
  
   end
  
end