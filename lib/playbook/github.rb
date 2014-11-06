require 'playbook/version'
require 'playbook'
require 'github_api'

module Playbook
module Github

  @@github = nil

  def configure
    @@github = ::Github::Client.new

    if block_given? then
      yield @@github
    end
  end

  def parse(number)
    issue = @@github.issues.get(:user => @@github.user, :repo => @@github.repo, :number => number).body

    playbook = Playbook.parse(issue.body)

    match = issue.body.scan(/#([0-9]+)/)
    if match.size > 0 then
      match.map{|m| m.first }.each do |issue_id|
        scenario_issue = @@github.issues.get(:user => @@github.user, :repo => @@github.repo, :number => number).body
        book = Playbook.parse(scenario_issue.body)
        playbook.merge(book)
      end
    end

    playbook
  end

  module_function :configure, :parse
end
end
