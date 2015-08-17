module EagleSearch
  class Field
    def initialize(index, column, settings)
      @index    = index
      @column   = column
      @settings = settings
    end

    def mapping
      mapping = { type: type }

      if type == "string"
        if @settings[:unsearchable]
          mapping[:index] = "no"
        else
          if @settings[:exact_match]
            mapping[:index] = "not_analyzed"
          else
            mapping[:index] = "analyzed"
            mapping[:analyzer] = @index.settings[:language] || "english"
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
