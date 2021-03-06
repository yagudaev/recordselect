module RecordSelect
  module Conditions
    protected
    # returns the combination of all conditions.
    # conditions come from:
    # * current search (params[:search])
    # * intelligent url params (e.g. params[:first_name] if first_name is a model column)
    # * specific conditions supplied by the developer
    def record_select_conditions
      conditions = []

      merge_conditions(
        record_select_conditions_from_search,
        record_select_conditions_from_params,
        record_select_conditions_from_controller
      )
    end

    # an override method.
    # here you can provide custom conditions to define the selectable records. useful for situational restrictions.
    def record_select_conditions_from_controller; end

    # another override method.
    # define any association includes you want for the finder search.
    def record_select_includes; end

    def record_select_like_operator
      @like_operator ||= ::ActiveRecord::Base.connection.adapter_name == "PostgreSQL" ? "ILIKE" : "LIKE"
    end

    # define special list of selected fields,
    # mainly to define extra fields that can be used for 
    # specialized sorting.
    def record_select_select
      '*'
    end

    # generate conditions from params[:search]
    # override this if you want to customize the search routine
    def record_select_conditions_from_search
      search_pattern = record_select_config.full_text_search? ? '%?%' : '?%'

      if params[:search] and !params[:search].strip.empty?
        if record_select_config.full_text_search?
          tokens = params[:search].strip.split(' ')
        else
          tokens = []
          tokens << params[:search].strip
        end

        where_clauses = record_select_config.search_on.collect { |sql| "#{sql} #{record_select_like_operator} ?" }
        phrase = "(#{where_clauses.join(' OR ')})"

        sql = ([phrase] * tokens.length).join(' AND ')
        tokens = tokens.collect{ |value| [search_pattern.sub('?', value)] * record_select_config.search_on.length }.flatten

        conditions = [sql, *tokens]
      end
    end

    # generate conditions from the url parameters (e.g. users/browse?group_id=5)
    def record_select_conditions_from_params
      conditions = nil
      params.each do |field, value|
        next unless column = record_select_config.model.columns_hash[field]
        conditions = merge_conditions(
          conditions,
          record_select_condition_for_column(column, value)
        )
      end
      conditions
    end

    # generates an SQL condition for the given column/value
    def record_select_condition_for_column(column, value)
      model = record_select_config.model
      column_name = model.quoted_table_name + '.' + model.connection.quote_column_name(column.name)
      if value.blank? and column.null
        "#{column_name} IS NULL"
      elsif column.text?
        ["LOWER(#{column_name}) LIKE ?", value]
      else
        ["#{column_name} = ?", column.type_cast(value)]
      end
    end

    def merge_conditions(*conditions) #:nodoc:
      c = conditions.find_all {|c| not c.nil? and not c.empty? }
      c.empty? ? nil : c.collect{|c| record_select_config.model.send(:sanitize_sql, c)}.join(' AND ')
    end
  end
end
