module EagleSearch
  class Field
    def initialize(index, column)
      @index    = index
      @column   = column
    end

    def mapping
      mapping = { type: type }
      index_settings = @index.settings

      mapping[:index] = "no" if index_settings[:unsearchable_fields] && (index_settings[:unsearchable_fields].include?(@column.name) || index_settings[:unsearchable_fields].include?(@column.name.to_sym))

      unless mapping[:index]
        if type == "string"
          if index_settings[:exact_match_fields] && (index_settings[:exact_match_fields].include?(@column.name) || index_settings[:exact_match_fields].include?(@column.name.to_sym))
            mapping[:index] = "not_analyzed"
          else
            mapping[:index] = "analyzed"
            mapping[:analyzer] = index_settings[:language] || "english"
          end
        end
      end

      mapping
    end

    private
    def type
      case @column.type
      when :integer
        if @column.limit.to_i <= 8
          "integer"
        else
          "long"
        end
      when :date, :datetime
        "date"
      when :boolean
        "boolean"
      when :decimal, :float
        "float"
      else
        "string"
      end
    end
  end
end