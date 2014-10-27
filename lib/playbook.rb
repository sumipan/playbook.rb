require "playbook/version"
require "stringio"

module Playbook
  class Book
    attr_reader :chapters

    def initialize
      @chapters = []
    end

    def add_chapter(chapter)
      @chapters.push chapter
      @chapters.sort! { |a,b| a.number <=> b.number }
    end

    def register_index(root)
      index = 1
      root.each do |node|
        case node.class.to_s
        when 'Hash'
          chapter = Chapter.new(:name => node[:name], :number => index)

          if node[:scenes] && node[:scenes].class == Array then
            n = 1
            node[:scenes].each do |scene|
              scene = Scene.new(:name => scene[:name], :number => n)
              n += 1
              chapter.add_scene(scene)
            end
          end
        when 'String'
          add_chapter(Chapter.new(:name => node, :number => index))
        end

        index += 1
      end
    end

    def merge(playbook)
      playbook.chapters.each do |source_chapter|
        chapter = @chapters.select{|chapter| chapter.name == source_chapter.name }.first
        unless chapter then
          add_chapter(source_chapter)
        else
          source_chapter.scenes.each do |source_scene|
            scene = chapter.scenes.select{|scene| scene.name == source_scene.name}.first
            unless scene then
              chapter.add_scene(source_scene)
            else
              source_scene.scenarios.each do |scenario|
                scene.add_scenario(scenario)
              end
            end
          end
        end
      end

      self
    end

    def to_s
      io = StringIO.new

      @chapters.each do |chapter|
        io.puts sprintf('chapter: %s', chapter.name) unless chapter.name == ''
        chapter.scenes.each do |scene|
          scene.scenarios.each do |scenario|
            io.puts sprintf('%s: %s', scene.name, scenario.text)
          end
        end
        io.puts ''
      end

      string = io.string
      io.close

      return string
    end
  end

  class Chapter
    attr_reader :name, :number, :scenes

    def initialize(attributes = {})
      @scenes = []
      @name   = attributes[:name]
      @number = attributes[:number] || 0
    end

    def add_scene(scene)
      @scenes.push scene
      @scenes.sort! { |a,b| a.number <=> b.number }
    end
  end

  class Scene
    attr_reader :name, :number, :scenarios

    def initialize(attributes = {})
      @name   = attributes[:name]
      @number = attributes[:number] || 0
      @scenarios = attributes[:scenarios] || []
    end

    def add_scenario(scenario)
      scenarios.push scenario
    end
  end

  class Scenario
    attr_accessor :text, :author, :book_number, :chapter

    def initialize(attributes = {})
      @text   = attributes[:text]
      @author = attributes[:author] || ''
      @chapter = attributes[:chapter] || nil
      @book_number = attributes[:book_number] || 0
    end
  end

  def parse(input_text, author=nil)
    playbook = Book.new

    rough_books = input_text.scan(/```book(.+?)```/m).to_a
    rough_books.each do |rough_book|
      chapter_name = ''
      scene_name = nil
      rough_book[0].strip.split(/\r?\n/).each do |sentence|
        sentence = sentence.strip
        case sentence
        when /^chapter:/
          chapter_name = sentence.match(/^chapter: *(.+)$/)[1]
        when /^scene:/
          scene_name = sentence.match(/^scene: *(.+)$/)[1]
        when /^scenario:/
          raise 'error: scene not set' if scene_name == nil
          chapter = playbook.chapters.select{|chapter| chapter.name == chapter_name }.first
          unless chapter then
            chapter = Playbook::Chapter.new(:name => chapter_name)
            playbook.add_chapter(chapter)
          end

          scene = chapter.scenes.select{|scene| scene.name == scene_name }.first
          unless scene then
            scene = Playbook::Scene.new(:name => scene_name)
            chapter.add_scene(scene)
          end

          scene.add_scenario(Scenario.new(
            :text   => sentence.match(/^scenario: *(.+)*$/)[1],
            :author => author
          ))
        end
      end
    end

    playbook
  end

  module_function :parse
end
