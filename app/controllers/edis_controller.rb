# frozen_string_literal: true

class EdisController < ApplicationController
  def new
    render
  end

  def create
    parse_content
    extract_values
  end

  private

    def get_parser
      config = Stupidedi::Config.contrib(Stupidedi::Config.hipaa(Stupidedi::Config.default))
      Stupidedi::Builder::StateMachine.build(config)
    end

    def parse_content
      @content = params[:edi][:file].tempfile.read
      @content.force_encoding("ISO-8859-1")
      @parser, _r = get_parser.read(Stupidedi::Reader.build(@content))
    end

    def extract_values
      @values = []
      @headers = []
      cursor = @parser.first
      while cursor.defined?
        cursor = cursor.flatmap do |current|
          current_node = current.segment.fetch.node
          @headers << current_node.definition.name
          @values << current_node.children.collect { |current|  [current.definition.name, current.try(:value)] }
          current.next
        end
      end
    end
end
