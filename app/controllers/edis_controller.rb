# frozen_string_literal: true

class EdisController < ApplicationController
  before_action :load_edi, only: [:show]

  def new
    render
  end

  def create
    parse_content
    extract_values
    edi = store_edi
    redirect_to(edi)
  end

  def show
    render
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
      index = 0
      split_content = @content.split("\r\n")
      @parsed_content = {}
      cursor = @parser.first
      while cursor.defined?
        cursor = cursor.flatmap do |current|
          current_node = current.segment.fetch.node
          @parsed_content[current_node.definition.name] = { index: index,
                                                            values: current_node.children.collect { |current|  [current.definition.name, current.try(:value)] },
                                                            line: split_content[index] }
          index += 1
          current.next
        end
      end
    end

    def store_edi
      Edi.create! file_content: @content, parsed_content: @parsed_content, parsing_errors: {}
    end

    def load_edi
      @edi = Edi.find(params[:id])
    end
end
