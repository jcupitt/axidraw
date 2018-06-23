# simple SVG generator

# example:
#
# Svg.new $stdout, viewBox: "0 0 1000 1000" do |svg|
#     svg.line 0, 0, 400, 400, style: "stroke: black; stroke-width: 1" 
# end

class Svg
    def attrs options
        a = []
        options.each do |name, value|
            a << "#{name}=\"#{value}\""
        end

        a.join " "
    end

    def element name, options, block
        if block
            @output.puts "#{" " * @indent}<#{name} #{attrs(options)}>"
            @indent += 2
            block.call self
            @indent -= 2
            @output.puts "#{" " * @indent}</#{name}>"
        else
            @output.puts "#{" " * @indent}<#{name} #{attrs(options)}/>"
        end
    end

    def initialize output, options={}, &block
        @layer = 1
        @indent = 0
        @output = output
        options = options.merge xmlns: "http://www.w3.org/2000/svg",
            "xmlns:inkscape" => "http://www.inkscape.org/namespaces/inkscape",
            width: "420mm",
            height: "297mm"
        element "svg", options, block
    end

    def g options={}, &block
        element "g", options, block
    end

    def layer name, options={}, &block
        options = options.merge "inkscape:groupmode" => "layer",
                id: "layer#{@layer}",
                "inkscape:label" => "#{@layer} - #{name}" 
        @layer += 1
        element "g", options, block
    end

    def line x1, y1, x2, y2, options={}, &block
        options = options.merge x1: x1, y1: y1, x2: x2, y2: y2
        element "line", options, block
    end

    def svgtxt txt
        @output.puts "#{" " * @indent}#{txt}"
    end

end
