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

  # make a SVG A element for a section of an arc
  def arc_path(c, r, sa, sweep)
    sx, sy = add([r * Math.cos(sa), r * Math.sin(sa)], c)
    ex, ey = add([r * Math.cos(sa + sweep), r * Math.sin(sa + sweep)], c)
    fa = sweep > Math::PI ? 1 : 0
    fs = sweep > 0 ? 1 : 0

    "M #{sx} #{sy} A #{r} #{r} 0 #{fa} #{fs} #{ex} #{ey}"
  end

  # a spiral moving in as a set of arcs
  def spiral_path(c, r, sa, t)
    sx, sy = add([r * Math.cos(sa), r * Math.sin(sa)], c)
    d = "M #{sx} #{sy} "

    (0 .. t).step(0.25).each do |i|
      ar = r - i
      aa = sa + i * 4 * Math::PI
      ex, ey = add([ar * Math.cos(aa), ar * Math.sin(aa)], c)
      d += "A #{ar} #{ar} 0 0 1 #{ex} #{ey} "
    end

    d
  end

  # draw a circle using an overlapping path with a random start and end angle ..
  # this helps to hide the pen up and pen down points
  def circle_path(c, r)
    sa = 2 * Random.rand * Math::PI
    sweep = 1.1 * Math::PI
    "#{arc_path(c, r, sa, sweep)} #{arc_path(c, r, sa + sweep, sweep)}"
  end

  # draw a thick circle as outer, inward spiral, inner
  def circle_thick_path(c, r, t)
    sa = 0.5 * Random.rand * Math::PI
    "#{circle_path(c, r)} #{spiral_path(c, r, sa, t)} #{circle_path(c, r - t)}"
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

  def circle(c, r, options={}, &block)
    # don't use SVG circle -- that will leave marks for penup and pendown
    d = circle_path(c, r)
    options = options.merge d: d
    element "path", options, block
  end

  def circle_thick(c, r, t, options={}, &block)
    t = [r, t].min
    if t == 0
      d = circle_path(c, r)
    else
      d = circle_thick_path(c, r, t)
    end
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
