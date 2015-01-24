module ActiveRecord
  module Collections
    module Batching
      def paginated?
        !(@page.nil? && @per.nil?)
      end
      alias_method :batched?, :paginated?

      def current_page
        @page || 1
      end
      alias_method :current_batch, :current_page

      def per_page
        @per || total_count
      end
      alias_method :per_batch, :per_page

      def total_pages
        total_count / per_page
      end
      alias_method :total_batches, :total_pages

      def each_page(&block)
        if total_pages <= 1
          yield records if block_given?
          return [records]
        end

        page!(1)
        paged = []
        while !records.empty? do
          paged << records
          yield records if block_given?
          next_page!
        end
        paged
      end
      alias_method :each_batch, :each_page

      def page_map(&block)
        if total_pages <= 1
          return (block_given? ? yield(records) : records)
        end

        page!(1)
        paged = []
        while !records.empty? do
          paged << (block_given? ? yield(records) : records)
          page!(current_page + 1)
        end
        paged
      end
      alias_method :batch_map, :page_map

      def flat_page_map(&block)
        page_map(&block).flatten
      end
      alias_method :flat_batch_map, :flat_page_map

      def first_page
        dup.first_page!
      end
      alias_method :first_batch, :first_page

      def first_page!
        page!(1)
      end
      alias_method :first_batch!, :first_page!

      def next_page?
        current_page < total_pages
      end
      alias_method :next_batch?, :next_page?

      def next_page
        dup.next_page!
      end
      alias_method :next_batch, :next_page

      def next_page!
        page!(current_page + 1) if next_page?
      end
      alias_method :next_batch!, :next_page!

      def prev_page?
        current_page > 1
      end
      alias_method :prev_batch?, :prev_page?

      def prev_page
        dup.prev_page!
      end
      alias_method :prev_batch, :prev_page

      def prev_page!
        page!(current_page - 1) if prev_page?
      end
      alias_method :prev_batch!, :prev_page!

      def last_page
        dup.last_page!
      end
      alias_method :last_batch, :last_page

      def last_page!
        page!(total_pages)
      end
      alias_method :last_batch!, :last_page!
    end
  end
end