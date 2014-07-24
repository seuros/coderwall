module ProtipSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name "protips-#{Rails.env}"
    document_type 'protip'

    settings analysis: {
        analyzer: {
            tags: {type: 'pattern',
                   pattern: ',',
                   filter: 'keyword'
            }

        }
    }

    mapping show: {properties: {
        public_id: {type: 'string', index: 'not_analyzed'},
        kind: {type: 'string', index: 'not_analyzed'},
        title: {type: 'string', boost: 100, analyzer: 'snowball'},
        body: {type: 'string', boost: 80, analyzer: 'snowball'},
        html: {type: 'string', index: 'not_analyzed'},
        tags: {type: 'string', boost: 80, analyzer: 'tags'},
        upvotes: {type: 'integer', index: 'not_analyzed'},
        url: {type: 'string', index: 'not_analyzed'},
        upvote_path: {type: 'string', index: 'not_analyzed'},
        popular_score: {type: 'double', index: 'not_analyzed'},
        score: {type: 'double', index: 'not_analyzed'},
        trending_score: {type: 'double', index: 'not_analyzed'},
        only_link: {type: 'string', index: 'not_analyzed'},
        link: {type: 'string', index: 'not_analyzed'},
        team: {type: 'multi_field', index: 'not_analyzed', fields: {
            name: {type: 'string', index: 'snowball'},
            slug: {type: 'string', boost: 50, index: 'snowball'},
            avatar: {type: 'string', index: 'not_analyzed'},
            profile_path: {type: 'string', index: 'not_analyzed'},
            hiring: {type: 'boolean', index: 'not_analyzed'}
        }},
        views_count: {type: 'integer', index: 'not_analyzed'},
        comments_count: {type: 'integer', index: 'not_analyzed'},
        best_stat: {type: 'multi_field', index: 'not_analyzed', fields: {
            name: {type: 'string', index: 'not_analyzed'},
            value: {type: 'integer', index: 'not_analyzed'},
        }},
        comments: {type: 'object', index: 'not_analyzed', properties: {
            title: {type: 'string', boost: 100, analyzer: 'snowball'},
            body: {type: 'string', boost: 80, analyzer: 'snowball'},
            likes: {type: 'integer', index: 'not_analyzed'}
        }},
        networks: {type: 'string', boost: 50, analyzer: 'tags'},
        upvoters: {type: 'integer', boost: 50, index: 'not_analyzed'},
        created_at: {type: 'date', boost: 10, index: 'not_analyzed'},
        featured: {type: 'boolean', index: 'not_analyzed'},
        flagged: {type: 'boolean', index: 'not_analyzed'},
        created_automagically: {type: 'boolean', index: 'not_analyzed'},
        reviewed: {type: 'boolean', index: 'not_analyzed'},
        user: {type: 'multi_field', index: 'not_analyzed', fields: {
            username: {type: 'string', boost: 40, index: 'not_analyzed'},
            name: {type: 'string', boost: 40, index: 'not_analyzed'},
            user_id: {type: 'integer', boost: 40, index: 'not_analyzed'},
            profile_path: {type: 'string', index: 'not_analyzed'},
            avatar: {type: 'string', index: 'not_analyzed'},
            about: {type: 'string', index: 'not_analyzed'},
        }}}}

    def as_indexed_json(options={})
      {
          public_id: public_id,
          kind: kind,
          title: Sanitize.clean(title),
          body: body,
          html: Sanitize.clean(to_html),
          tags: topics,
          upvotes: upvotes,
          url: path,
          upvote_path: upvote_path,
          link: link,
          created_at: created_at,
          featured: featured,
          trending_score: trending_score,
          popular_score: value_score,
          score: score,
          upvoters: upvoters_ids,
          comments_count: comments.count,
          views_count: total_views,
          comments: comments.map do |comment|
            {
                title: comment.title,
                body: comment.comment,
                likes: comment.likes_cache
            }
          end,
          networks: networks.map(&:name).map(&:downcase).join(","),
          best_stat: Hash[*[:name, :value].zip(best_stat.to_a).flatten],
          team: user && user.team && {
              name: user.team.name,
              slug: user.team.slug,
              avatar: user.team.avatar_url,
              profile_path: Rails.application.routes.url_helpers.teamname_path(slug: user.team.try(:slug)),
              hiring: user.team.hiring?
          },
          only_link: only_link?,
          user: user && {user_id: user.id},
          flagged: flagged?,
          created_automagically: created_automagically?,
          reviewed: viewed_by_admin?,
          tag_ids: topic_ids
      }
    end

    #TODO REMOVE
    after_save :index_search
    after_save :unqueue_flagged, if: :flagged?
    after_destroy :index_search_after_destroy

    def deindex_search
      ProtipIndexer.new(self).remove
    end
    def index_search
      ProtipIndexer.new(self).store
    end

    def index_search_after_destroy
      self.tire.update_index
    end

    def unqueue_flagged
      ProcessingQueue.unqueue(self, :auto_tweet)
    end
  end

  module ClassMethods
    def search_next(query, tag, index, page)
      # when your viewing a protip if we don't check this it
      # thinks we came from trending and shows the next trending protip eventhough we directly landed here
      # TODO, refactor then
      return nil if page.nil? || (tag.blank? && query.blank?)
      page = (index.to_i * page.to_i) + 1
      tag = [tag] unless tag.is_a?(Array) || tag.nil?
      search_by_string(query, tag, page: page, per_page: 1).results.try(:first)
    end

    #TODO Refactor
    def search_by_string(query_string, tags =[])
      # query, team, author, bookmarked_by, execution, sorts= preprocess_query(query_string)
      # tags = [] if tags.nil?
      # tags = preprocess_tags(tags)
      # tag_ids = process_tags_for_search(tags)
      # tag_ids = [0] if !tags.blank? and tag_ids.blank?
      # filters = []
      # filters << {term: {upvoters: bookmarked_by}} unless bookmarked_by.nil?
      # filters << {term: {'user.user_id' => author}} unless author.nil?
        Protip.__elasticsearch__.search(
            {
                query: {
                    query_string: {
                        query: query_string,
                        default_operator: 'AND',
                        use_dis_max: true
                    }
                }
            }
        )
          # query { string query, default_operator: 'AND', use_dis_max: true } unless query.blank?
          # filter :terms, tag_ids: tag_ids, execution: execution unless tag_ids.blank?
          # filter :term, teams: team unless team.nil?
          # if filters.size >= 2
          #   filter :or, *filters
          # else
          #   filters.each do |fltr|
          #     filter *fltr.first
          #   end
          # end
          # sort { by [sorts] }
          #sort { by [{:upvotes => 'desc' }] }
        # end
    end

    def popular
      Protip::Search.new(Protip,
                         nil,
                         nil,
                         Protip::Search::Sort.new(:popular_score),
                         nil,
                         nil).execute
    end

    def trending
      Protip::Search.new(Protip,
                         nil,
                         nil,
                         Protip::Search::Sort.new(:trending_score),
                         nil,
                         nil).execute
    end

    def trending_for_user(user)
      Protip::Search.new(Protip,
                         nil,
                         Protip::Search::Scope.new(:user, user),
                         Protip::Search::Sort.new(:trending_score),
                         nil,
                         nil).execute
    end

    def hawt_for_user(user)
      Protip::Search.new(Protip,
                         Protip::Search::Query.new('best_stat.name:hawt'),
                         Protip::Search::Scope.new(:user, user),
                         Protip::Search::Sort.new(:created_at),
                         nil,
                         nil).execute
    end

    def hawt
      Protip::Search.new(Protip,
                         Protip::Search::Query.new('best_stat.name:hawt'),
                         nil,
                         Protip::Search::Sort.new(:created_at),
                         nil,
                         nil).execute
    end

    def trending_by_topic_tags(tags)
      trending.topics(tags.split("/"), true)
    end

    def top_trending(page = 1, per_page = Protip::PAGESIZE)
      page = 1 if page.nil?
      per_page = Protip::PAGESIZE if per_page.nil?
      search_trending_by_topic_tags(nil, [], page, per_page)
    end

    def search_trending_by_team(team_id, query_string, page, per_page)
      query = "team.name:#{team_id.to_s}"
      query += " #{query_string}" unless query_string.nil?
      Protip.search_by_string(query, [], page: page, per_page: per_page)
    rescue Errno::ECONNREFUSED
      team = Team.where(slug: team_id).first
      team.team_members.collect(&:protips).flatten
    end

    def search_trending_by_user(username, query_string, tags, page, per_page)
      query = "author:#{username}"
      query += " #{query_string}" unless query_string.nil?
      Protip.search_by_string(query, tags, page: page, per_page: per_page)
    end

    def search_trending_by_topic_tags(query, tags, page, per_page)
      Protip.search_by_string(query, tags, page: page, per_page: per_page)
    end

    def search_trending_by_date(query, date, page, per_page)
      date_string = "#{date.midnight.strftime('%Y-%m-%dT%H:%M:%S')} TO #{(date.midnight + 1.day).strftime('%Y-%m-%dT%H:%M:%S')}" unless date.is_a?(String)
      query = "" if query.nil?
      query += " created_at:[#{date_string}]"
      Protip.search_by_string(query, [], page: page, per_page: per_page)
    end

    #TODO USE
    def search_bookmarked_protips(username, page, per_page)
      Protip.search_by_string("bookmark:#{username}", [], page: page, per_page: per_page)
    end

    #TODO USE
    def most_interesting_for(user, since=Time.at(0), page = 1, per_page = 10)
      search_top_trending_since("only_link:false", since, user.networks.map(&:ordered_tags).flatten.concat(user.skills.map(&:name)), page, per_page)
    end

    #TODO USE
    def search_top_trending_since(query, since, tags, page = 1, per_page = 10)
      query ||= ''
      query += " created_at:[#{since.strftime('%Y-%m-%dT%H:%M:%S')} TO *] sort:upvotes desc"
      search_trending_by_topic_tags(query, tags, page, per_page)
    end

    #TODO REFACTOR
    def preprocess_query(query_string)
      query = team = nil
      unless query_string.nil?
        query = query_string.dup
        query.gsub!(/(\d+)\"/, "\\1\\\"") #handle 27" cases
        team = query.gsub!(/(team:([0-9A-Z\-]+))/i, "") && $2
        team = (team =~ /^[a-f0-9]+$/i && team.length == 24 ? team : Team.where(slug: team).first.try(:id))
        author = query.gsub!(/author:([^\. ]+)/i, "") && $1.try(:downcase)
        author = User.find_by_username(author).try(:id) || 0 unless author.nil? or (author =~ /^\d+$/)
        bookmarked_by = query.gsub!(/bookmark:([^\. ]+)/i, "") && $1
        bookmarked_by = User.find_by_username(bookmarked_by).try(:id) unless bookmarked_by.nil? or (bookmarked_by =~ /^\d+$/)
        execution = query.gsub!(/execution:(plain|bool|and)/, "") && $1.to_sym
        sorts_string = query.gsub!(/sort:([[\w\d_]+\s+(desc|asc),?]+)/i, "") && $1
        sorts = Hash[sorts_string.split(",").map { |sort| sort.split(/\s/) }] unless sorts_string.nil?
        flagged = query.gsub!(/flagged:(true|false)/, "") && $1 == "true"
        query.gsub!(/\!{2,}\s*/, "") unless query.nil?

      end
      execution = :plain if execution.nil?
      sorts = {created_at: 'desc'} if sorts.blank?
      flagged = false if flagged.nil?
      query = "#{query} flagged:#{flagged}"

      [query, team, author, bookmarked_by, execution, sorts]
    end

    #TODO REFACTOR
    def preprocess_tags(tags)
      tags.collect do |tag|
        preprocess_tag(tag)
      end unless tags.nil?
    end

    #TODO REFACTOR 50%
    def preprocess_tag(tag)
      tag.downcase.strip.to_s[Protip::VALID_TAG, 0]
    end

    #TODO REFACTOR
    def process_tags_for_search(tags)
      tags.blank? ? [] : ActiveRecord::Base.connection.select_values(Tag.where(name: tags).select(:id).to_sql).map(&:to_i)
    end

    def trending_topics
      trending_protips = search_by_string(nil, [], page: 1, per_page: 100)

      unless trending_protips.respond_to?(:errored?) and trending_protips.errored?
        static_trending = ENV['FEATURED_TOPICS'].split(",").map(&:strip).map(&:downcase) unless ENV['FEATURED_TOPICS'].blank?
        dynamic_trending = trending_protips.map { |p| p.tags }.flatten.reduce(Hash.new(0)) { |h, tag| h.tap { |h| h[tag] += 1 } }.sort { |a1, a2| a2[1] <=> a1[1] }.map { |entry| entry[0] }.reject { |tag| User.where(username: tag).any? }
        ((static_trending || []) + dynamic_trending).uniq
      else
        Tag.last(20).map(&:name).reject { |name| User.exists?(username: name) }
      end
    end

  end
end
