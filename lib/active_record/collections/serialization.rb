module ActiveRecord
  module Collections
    module Serialization
      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods
        def from_json(json)
          from_hash JSON.load(json)
        end

        def from_hash(hash)
          hash.symbolize_keys!
          collection = new(hash[:klass])
          collection.select!(*hash[:select]) unless hash[:select].empty?
          collection.distinct! if hash[:distinct] == true
          collection.joins!(*hash[:joins]) unless hash[:joins].empty?
          collection.references!(*hash[:references]) unless hash[:references].empty?
          collection.includes!(*hash[:includes]) unless hash[:includes].empty?
          collection.where!(*hash[:bind].map { |b| b[:value] }.unshift(hash[:where].join(" AND ").gsub(/\$\d/,'?'))) unless hash[:where].empty?
          collection.order!(hash[:order]) unless hash[:order].empty?
          collection.limit!(hash[:limit]) unless hash[:limit].nil?
          collection.offset!(hash[:offset]) unless hash[:offset].nil?
          collection
        end
      end

      def to_sql
        relation.to_sql
      end

      def to_hash(include_limit=false)
        h = {
          select:     relation.select_values,
          distinct:   relation.distinct_value,
          joins:      relation.joins_values,
          references: relation.references_values,
          includes:   relation.includes_values,
          where:      relation.where_values.map { |v| v.is_a?(String) ? v : v.to_sql },
          order:      relation.order_values.map { |v| v.is_a?(String) ? v : v.to_sql },
          bind:       relation.bind_values.map { |b| {name: b.first.name, value: b.last} }
        }
        if include_limit || try(:is_batch?)
          h[:limit] = relation.limit_value
          h[:offset] = relation.offset_value
        end
        h
      end
      alias_method :to_h, :to_hash

      def to_json(options=nil)
        to_hash.to_json
      end

      def to_param
        to_json
      end
    end
  end
end
