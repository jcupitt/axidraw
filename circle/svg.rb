# simple SVG generator

# example:
#
# Svg.new $stdout, viewBox: "0 0 1000 1000" do |svg|
#     svg.line [0, 0], [400, 400], style: "stroke: black; stroke-width: 1" 
# end

def midpoint(*points)
  points.transpose.map{|x| x.sum.to_f / points.length}
end

def length(v)
  Math.sqrt(v.map{|x| x ** 2}.sum)
end

def sub(a, b)
  a.zip(b).map{|(x, y)| x - y}
end

def add(a, b)
  a.zip(b).map{|(x, y)| x + y}
end

class Svg

  # a path for a solid disc of ink ... spiral out from the centre, then draw a
  # circle, then spiral in slightly
  def disc_path(c, r)
    sx, sy = c
    a = 0
    d = "M #{sx} #{sy} "

    # spiral out from the centre 
    if r > 1
      (0.25 .. r - 0.125).step(0.5).each do |i|
        ar = i
        a += Math::PI
        ex, ey = add([ar * Math.cos(a), ar * Math.sin(a)], c)
        d += "A #{ar} #{ar} 0 0 1 #{ex} #{ey} "
      end
    end

    # draw a true circle exactly at r
    a += Math::PI
    ex, ey = add([r * Math.cos(a), r * Math.sin(a)], c)
    d += "A #{r} #{r} 0 0 1 #{ex} #{ey} "
    a += Math::PI
    ex, ey = add([r * Math.cos(a), r * Math.sin(a)], c)
    d += "A #{r} #{r} 0 0 1 #{ex} #{ey} "

    # spiral in slightly to hide penup
    if r > 2
      (0 .. 2.5).step(0.5).each do |i|
        ar = r - i
        a += Math::PI
        ex, ey = add([ar * Math.cos(a), ar * Math.sin(a)], c)
        d += "A #{ar} #{ar} 0 0 1 #{ex} #{ey} "
      end
    end

    d
  end

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
    # the full plot range of an axidraw A3 is 430 by 297mm ... knock 2mm off to
    # allow a 1mm margin
    options = options.merge xmlns: "http://www.w3.org/2000/svg",
      "xmlns:inkscape" => "http://www.inkscape.org/namespaces/inkscape",
      width: "428mm",
      height: "295mm"
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

  def line((x1, y1), (x2, y2), options={}, &block)
    options = options.merge x1: x1, y1: y1, x2: x2, y2: y2
    element "line", options, block
  end

  def circle((cx, cy), r, options={}, &block)
    options = options.merge cx: cx, cy: cy, r: r, fill: "none"
    element "circle", options, block
  end

  def disc(c, r, options={}, &block)
    d = disc_path(c, r)
    options = options.merge d: d
    element "path", options, block
  end

  def polygon points, options={}, &block
    point_str = points.each {|p| "#{p[0]},#{p[1]}"}.join " "
    options = options.merge points: point_str
    element "polygon", options, block
  end

  def path d, options={}, &block
    options = options.merge d: d 
    element "path", options, block
  end

  def svgtxt txt
    @output.puts "#{" " * @indent}#{txt}"
  end

end
