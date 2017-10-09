module Erlen; module Schema
  module Documentation
    #
    #
    #
    # @return a string in markdown representing the schema
    def to_markdown
      name = self.name.demodulize.gsub('Schema', '')
      result = ["## #{name}", '', '> Example Response', '', '```json', '']

      result << '{'
      # JSON EXAMPLE
      schema_attributes.each do |attr_name, attr|
        result << "  \"#{attr_name}\" : #{example_value(attr)},"
      end
      result << '}'
      result << '```'


      result.concat(class_attributes(self))
      result.join("\n")
    end

    def example_value(attr)
      if attr.type == Integer
        rand(100)
      elsif attr.type == String
        "\"#{attr.name.titleize.upcase}\""
      elsif attr.type == Time
        "\"#{Time.current}\""
      elsif attr.type == Date
        "\"#{Time.current}\""
      elsif attr.type == Boolean
        "\"#{rand(2) == 1}\""
      elsif attr.type < Base && attr.type.respond_to(:element_type)
        []
      else
        {}
      end
    end

    def class_attributes(klass)
      types = []
      result = [
        '',
        'Attributes | Type | Required | Description',
        '---------- | ---- | -------- | -----------'
      ]

      klass.schema_attributes.each do |attr_name, attr|
        if attr.type.respond_to?(:element_type)
          type_name = attr.type.element_type.name.demodulize.gsub('Schema', '').titleize
          result << "#{attr_name} | Array of #{type_name} | #{attr.options[:required]} | "
          types << attr.type.element_type if (attr.type.element_type < Base)
        elsif attr.type < Base
          type_name = attr.type.name.demodulize.gsub('Schema', '').titleize
          result << "#{attr_name} | #{type_name} | #{attr.options[:required]} | "
          types << attr.type
        else
          result << "#{attr_name} | #{attr.type} | #{attr.options[:required]} | "
        end
      end

      types.each do |t|
        result << ''
        result << "## #{t.name.demodulize.gsub('Schema', '')}"
        result << ''

        result.concat(class_attributes(t))
      end

      result
    end
  end
end; end
