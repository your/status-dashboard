# frozen_string_literal: true

module HasScopedLastUpdate
  extend ActiveSupport::Concern

  LastUpdate = Struct.new(:updated_at, :updated_by)

  class_methods do
    def last_update_by_scope(scope, with_updated_by: false)
      results = build_query(scope, with_updated_by)
      LastUpdate.new(*results)
    end

    private

    def build_query(scope, with_updated_by)
      attrs = %i[updated_at]
      base = where(scope:).order(updated_at: :desc)

      if with_updated_by
        attrs << :'users.email'
        base = base.includes(:updated_by)
      end

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
