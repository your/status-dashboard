# frozen_string_literal: true

module HasScopedLastUpdate
  extend ActiveSupport::Concern

  LastUpdate = Struct.new(:updated_at)

  class_methods do
    def last_update_by_scope(scope)
      results = build_query(scope)
      LastUpdate.new(*results)
    end

    private

    def build_query(scope)
      attrs = %i[updated_at]
      base = where(scope:).order(updated_at: :desc)

      base
        .where("#{table_name}.updated_at = #{sql_max_updated_at_by_scope(scope)}")
        .pluck(*attrs)
        .flatten
    end

    def sql_max_updated_at_by_scope(scope)
      <<~SQL
        (SELECT MAX(updated_at) FROM #{table_name} WHERE scope = '#{scope}')
      SQL
    end
  end
end
