module ParserOfficialSite
  class Specifications
    attr_accessor :name, :description
    def initialize name, description
      @name = name
      @description = description
    end
  end

  class Carparts
    attr_accessor :name, :specifications
    def initialize name
      @specifications = []
      @name = name
    end
  end

  class Engine
    attr_accessor :name, :carparts
    def initialize data, tth_types, engine
      @carparts = []

      @tth_types = tth_types.reverse
      # engine this element with class = "txt10"
      @engine = engine

      @name = engine.css('.txt11').text
      @data = data
    end
    # Params for only initialize 
    def make carparts=Object.new, tth_type_name=nil, tth_type_parameters=[]
      @engine.css('li').each do |li|
        cls = li.attributes["class"].try(:value)
         
        next if cls == 'first'

        # Always first initialize
        if cls == 'tth_eng_type'
          tth_type = @tth_types.pop
          tth_type_name = tth_type.name
          tth_type_parameters = tth_type.parameters.reverse

          carparts = Carparts.new( tth_type_name )
          @carparts.push carparts
          next
        end

        if li.attributes["title"].try(:value)
          carparts.specifications.push Specifications.new(tth_type_parameters.pop, li.attributes["title"].value)
        else
          carparts.specifications.push Specifications.new(tth_type_parameters.pop, li.text)
        end
      end
    end
  end
  
  class TthTypes
    attr_accessor :name, :parameters
    def initialize name
      @name = name
      @parameters = []
    end
  end

  class Tth
    attr_accessor :engines
    def initialize domain
      @engines = []
      @domain  = domain
    end

    def parse tth_type=Object.new
      data = get_content

      tth_types = []
      data.css('.tth_types').css('li').each do |li|
        cls = li.attributes["class"].try(:value)
        if cls == 'first'
          tth_type = TthTypes.new( li.text )
          tth_types.push tth_type
          next
        end

        tth_type.parameters.push li.attributes["title"].try(:value)
      end

      data.css('.txt10').each do |engine|
        obj = Engine.new(data, tth_types, engine)
        obj.make
        @engines.push obj
      end
    end

    private
      def get_content
        sleep 0.5
        content = open( @domain ) do |http|
          @html = http.read
        end
        # Parse content
        Nokogiri::HTML( content )
      end
  end
end
