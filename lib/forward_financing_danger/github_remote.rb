# frozen_string_literal: true

require 'base64'

module ForwardFinancingDanger
  class GithubRemote
    class FailedToFetch < StandardError; end

    def self.for(github)
      new(
        api:  github.api,
        repo: github.pr_json.head.repo.full_name,
        head: github.head_commit
      )
    end

    def initialize(api:, repo:, head:)
      @api  = api
      @repo = repo
      @head = head
      @memo = {}
    end

    def fetch(path)
      memo[path] ||= begin
        fetched = api.contents(repo, path: path, ref: head)
        Base64.decode64(fetched.content)
                     rescue StandardError => e
                       raise FailedToFetch, e.message
      end
    end

    private

    attr_reader :api, :repo, :head, :memo
  end
end
