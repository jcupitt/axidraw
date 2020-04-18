#!/usr/bin/env ruby

require_relative 'svg'

$layer_names = %w[
  red 
  green 
  blue 
  yellow 
  black 
  purple 
  orange 
  violet 
  magenta 
  cyan 
  teal
]

class Mesh
  def initialize
    # hash of point_id -> [x, y] pair
    @coordinates_of_point = {}
    @next_point_id = 0

    # hash of edge_id -> [p1, p2]
    @points_of_edge = {}
    @next_edge_id = 0

    # for each point, an array of the edges which connect to it
    @edges_of_point = Hash.new{[]}

    @length_of_edge = {}

    # hash of triangle_id -> [edge1_id, edge2_id, edge3_id]
    @edges_of_triangle = {}
    @next_triangle_id = 0

    # reverse of triangle table: edge_id -> [triangle1_id, ...]
    # in a non-overlapping 2D plane, a max of two triangles can use an edge
    @triangles_of_edge = Hash.new{[]}

    # triangles which have been created since we last iterated
    @new_triangles = []

    @checkpoint_id = 0

  end

  def to_s
    "coordinates_of_point = #{@coordinates_of_point}\n" +
    "points_of_edge = #{@points_of_edge}\n" +
    "edges_of_point = #{@edges_of_point}\n" +
    "length_of_edge = #{@length_of_edge}\n" +
    "edges_of_triangle = #{@edges_of_triangle}\n" +
    "triangles_of_edge = #{@triangles_of_edge}\n" +
    "new_triangles = #{@new_triangles}\n"
  end

  def add_point(x, y)
    pid = @next_point_id += 1
    @coordinates_of_point[pid] = [x, y]
    pid
  end

  def add_edge(p1, p2)
    eid = @next_edge_id += 1
    @points_of_edge[eid] = [p1, p2]
    x1, y1 = @coordinates_of_point[p1]
    x2, y2 = @coordinates_of_point[p2]
    @length_of_edge[eid] = ((x1 - x2) ** 2 + (y1 - y2) ** 2) ** 0.5
    # reverse mapping: points to edges
    @edges_of_point[p1] += [eid]
    @edges_of_point[p2] += [eid]
    eid
  end

  def add_triangle(e1, e2, e3)
    tid = @next_triangle_id += 1
    # sort edges by length, shortest first
    @edges_of_triangle[tid] = [e1, e2, e3].sort do |a, b| 
      @length_of_edge[a] - @length_of_edge[b]
    end
    # reverse mapping: edges to this triangle
    @triangles_of_edge[e1] += [tid]
    @triangles_of_edge[e2] += [tid]
    @triangles_of_edge[e3] += [tid]
    @new_triangles << tid
    tid
  end

  # remove an edge (don't check triangles that might be using it though our
  # caller must do that)
  def remove_edge(eid)
    p1, p2 = @points_of_edge[eid]
    @points_of_edge[eid] = nil
    @length_of_edge[eid] = nil

    @edges_of_point[p1] -= [eid]
    @edges_of_point[p2] -= [eid]
  end

  # remove a triangle (but don't touch the edges that make up the triangle --
  # our caller must do that)
  def remove_triangle(tid)
    edges = @edges_of_triangle[tid]
    @edges_of_triangle[tid] = nil

    edges.each do |eid|
      if ! @triangles_of_edge[eid].include? tid
        puts self
        raise "triangle #{tid} not attached to edge #{eid}"
      end
      @triangles_of_edge[eid] -= [tid]
    end
  end

  def acute?(tid)
    e1, e2, e3 = @edges_of_triangle[tid]
    l1 = @length_of_edge[e1]
    l2 = @length_of_edge[e2]
    l3 = @length_of_edge[e3]

    l1 ** 2 + l2 ** 2 > l3 ** 2
  end

  # return the point that two edges have in common, or nil
  def common_point(e1, e2)
    p1, p2 = @points_of_edge[e1]
    p3, p4 = @points_of_edge[e2]
    if p1 == p3 || p1 == p4
      p1
    elsif p2 == p3 || p2 == p4
      p2
    else
      nil
    end
  end

  def to_svg(filename)
    File.open filename, "w" do |file|
      Svg.new file, viewBox: "0 0 1024 707" do |svg|
        svg.rect width: "100%", height: "100%", fill: "white"
        @points_of_edge.each do |eid, points|
          next if points.nil?

          p1, p2 = points
          colour = $layer_names[eid % $layer_names.length]
          svg.line @coordinates_of_point[p1], @coordinates_of_point[p2], 
            style: "stroke: #{colour}; stroke-width: 0.7"
        end
      end
    end
  end

  def checkpoint
    @checkpoint_id += 1
    filename = "mesh-#{@checkpoint_id}.svg"
    puts "checkpoint: #{filename}"
    to_svg filename
  end

  def sanity_check
    @edges_of_triangle.each do |tid, edges|
      next if edges.nil?

      e1, e2, e3 = edges
      if common_point(e1, e2).nil? || 
          common_point(e2, e3).nil? || 
          common_point(e3, e1).nil?
        puts self
        raise "triangle #{tid} disconnected"
      end
    end

    @edges_of_point.each do |pid, edges|
      edges.each do |eid|
        if @points_of_edge[eid].nil?
          puts self
          raise "edge #{eid} in edges_of_point does not exist"
        end
      end
    end

    @triangles_of_edge.each do |eid, tids|
      next if tids.length == 0 

      if tids.length < 1 || tids.length > 2
        puts self
        raise "edge #{eid} in triangles_of_edge had a bad number of tris"
      end

      tids.each do |tid|
        if @edges_of_triangle[tid].nil?
          puts self
          raise "triangle #{tid} in triangles_of_edge does not exist"
        end
      end
    end

    checkpoint
  end

  # find the point that e1 and e2 share, or nil
  def common_point(e1, e2)
    p1, p2 = @edges[e1]
    p3, p4 = @edges[e2]
    if p1 == p3 || p1 == p4
      p1
    elsif p2 == p3 || p2 == p4
      p2
    else
      nil
    end
  end

  def sanity_check
    @triangles.each do |tid, edges|
      next if edges.nil?

      e1, e2, e3 = edges
      if common_point(e1, e2).nil? || 
        common_point(e2, e3).nil? || 
        common_point(e2, e1).nil? 
        puts self
        raise "triangle #{tid} is disconnected"
      end
    end

    @triangles_of_edge.each do |eid, triangles|
      triangles.each do |tid|
        edges = @triangles[tid]
        if ! edges.include?(eid)
          puts self
          raise "triangle #{tid} not in triangles_of_edge"
        end
      end
    end
  end

  # split a triangle into three based on a point at the centre
  def divide(tid)
    # stored shortest edge first
    e1, e2, e3 = @edges_of_triangle[tid]
    p1, p2 = @points_of_edge[e1]

    # swap e2/e3 if necessary so that e1 and e3 share p1
    p3, p4 = @points_of_edge[e3]
    if p3 != p1 && p4 != p1
      e2, e3 = e3, e2
      p3, p4 = @points_of_edge[e3]
    end

    # so the third point of the triangle is the one that's not p1 
    if p3 == p1 
      p3 = p4
    end

    x1, y1 = @coordinates_of_point[p1]
    x2, y2 = @coordinates_of_point[p2]
    x3, y3 = @coordinates_of_point[p3]
    pc = add_point((x1 + x2 + x3) / 3, (y1 + y2 + y3) / 3)

    remove_triangle(tid)

    e4 = add_edge(pc, p1)
    e5 = add_edge(pc, p2)
    e6 = add_edge(pc, p3)

    add_triangle(e1, e4, e5)
    add_triangle(e2, e5, e6)
    add_triangle(e3, e6, e4)

    # sanity_check
  end

  # join a triangle to its neighbour along the longest edge, then bisect along
  # the major axis
  def join(t1, t2)
    e1, e2, e3 = @edges_of_triangle[t1]

    # we want the two edges that are not e3
    raise "edge not shared" if ! @edges_of_triangle[t2].include?(e3)
    e4, e5 = @edges_of_triangle[t2].select{|x| x != e3}

    # swap e4/e5 if necessary so that e1 and e4 share a point
    if common_point(e1, e4).nil?
      e4, e5 = e5, e4
    end

    adjacent = common_point(e1, e2)
    opposite = common_point(e4, e5)

    remove_triangle(t1)
    remove_triangle(t2)
    remove_edge(e3)

    e6 = add_edge(opposite, adjacent)

    add_triangle(e1, e4, e6)
    add_triangle(e2, e5, e6)

    # sanity_check
  end

  def iterate
    tids = @new_triangles
    @new_triangles = []

    puts "processing #{tids.length} triangles ..."

    tids.each do |tid|
      next if @edges_of_triangle[tid].nil?

      # is this triangle's longest edge shared with another triangle's longest
      # edge?
      e1, e2, e3 = @edges_of_triangle[tid]
      tids = @triangles_of_edge[e3]
      if tids.length == 2 
        t2 = tids.select{|x| x != tid}.first
        e4, e5, e6 = @edges_of_triangle[t2]

        if e6 == e3 
          join(tid, t2)
          next
        end
      end

      divide(tid)
    end
  end

end

mesh = Mesh.new
p1 = mesh.add_point(0, 0)
p2 = mesh.add_point(1024, 0)
p3 = mesh.add_point(1024, 707)
p4 = mesh.add_point(0, 707)
p5 = mesh.add_point(500, 353)
p6 = mesh.add_point(524, 353)

e1 = mesh.add_edge(p1, p2)
e2 = mesh.add_edge(p2, p3)
e3 = mesh.add_edge(p3, p4)
e4 = mesh.add_edge(p4, p1)
e5 = mesh.add_edge(p4, p5)
e6 = mesh.add_edge(p1, p5)
e7 = mesh.add_edge(p1, p6)
e8 = mesh.add_edge(p5, p6)
e9 = mesh.add_edge(p5, p3)
e10 = mesh.add_edge(p6, p3)
e11 = mesh.add_edge(p6, p2)

t1 = mesh.add_triangle(e4, e5, e6)
t2 = mesh.add_triangle(e6, e8, e7)
t3 = mesh.add_triangle(e7, e11, e1)
t4 = mesh.add_triangle(e11, e2, e10)
t5 = mesh.add_triangle(e8, e9, e10)
t6 = mesh.add_triangle(e3, e5, e9)

10.times do |i|
  mesh.iterate
end

filename = "mesh.svg"
puts "writing #{filename} ..."
mesh.to_svg filename

