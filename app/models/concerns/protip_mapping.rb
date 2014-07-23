module ProtipMapping
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name    "protips-#{Rails.env}"
    document_type 'protip'

    settings analysis: {
        analyzer: {
            comma: {"type" => "pattern",
                    "pattern" => ",",
                    "filter" => "keyword"
            }

        }
    }

    mapping show: {properties: {
        public_id: {type: 'string', index: 'not_analyzed'},
        kind: {type: 'string', index: 'not_analyzed'},
        title: {type: 'string', boost: 100, analyzer: 'snowball'},
        body: {type: 'string', boost: 80, analyzer: 'snowball'},
        html: {type: 'string', index: 'not_analyzed'},
        tags: {type: 'string', boost: 80, analyzer: 'comma'},
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
        networks: {type: 'string', boost: 50, analyzer: 'comma'},
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

    def to_indexed_json
      to_public_hash.deep_merge(
        {
          trending_score:        trending_score,
          popular_score:         value_score,
          score:                 score,
          upvoters:              upvoters_ids,
          comments_count:        comments.count,
          views_count:           total_views,
          comments:              comments.map do |comment|
            {
              title: comment.title,
              body:  comment.comment,
              likes: comment.likes_cache
            }
          end,
          networks:              networks.map(&:name).map(&:downcase).join(","),
          best_stat:             Hash[*[:name, :value].zip(best_stat.to_a).flatten],
          team:                  user && user.team && {
            name:         user.team.name,
            slug:         user.team.slug,
            avatar:       user.team.avatar_url,
            profile_path: Rails.application.routes.url_helpers.teamname_path(slug: user.team.try(:slug)),
            hiring:       user.team.hiring?
          },
          only_link:             only_link?,
          user:                  user && { user_id: user.id },
          flagged:               flagged?,
          created_automagically: created_automagically?,
          reviewed:              viewed_by_admin?,
          tag_ids:               topic_ids
        }
      ).to_json(methods: [:to_param])
    end
  end
end
