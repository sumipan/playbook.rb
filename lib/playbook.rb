require "playbook/version"

module Playbook
  class Book
    attr_reader :scenes

    def initialize
      @scenes = []
    end

    def add_scenario(scene_name, scenario)
      scene = @scenes.select {|scene| scene.name == scene_name }.first
      unless scene
        scene = Scene.new(:name => scene_name)
        @scenes.push scene
      end

      scene.scenarios.push scenario

      nil
    end

    def merge(playbook)
      playbook.scenes.each do |scene|
        scene.scenarios.each do |scenario|
          add_scenario(scene.name, scenario)
        end
      end

      self
    end
  end

  class Scene
    attr_reader :name, :number, :scenarios

    def initialize(attributes = {})
      @name   = attributes[:name]
      @number = attributes[:number] || 0
      @scenarios = attributes[:scenarios] || []
    end
  end

  class Scenario
    attr_reader :text, :author

    def initialize(attributes = {})
      @text   = attributes[:text]
      @author = attributes[:author] || ''
    end
  end

  def parse(input_text, author=nil)
    playbook = Book.new

    rough_books = input_text.scan(/```book(.+?)```/m).to_a
    rough_books.each do |rough_book|
      scene_name = nil
      rough_book[0].strip.split(/\r?\n/).each do |sentence|
        case sentence
        when /^scene:/
          scene_name = sentence.match(/^scene: *(\S+) *$/)[1]
        when /^scenario:/
          raise 'error: scene not set' if scene_name == nil
          playbook.add_scenario(scene_name, Scenario.new(
            :text   => sentence.match(/^scenario: *(\S+) *$/)[1],
            :author => author
          ))
        end
      end
    end

    playbook
  end

  module_function :parse
end
