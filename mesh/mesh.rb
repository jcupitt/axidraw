#!/usr/bin/env ruby

require_relative 'svg'

class Mesh
  def initialize
    # hash of point_id -> [x, y] points
    @points = {}
    @next_point_id = 0

    # hash of edge_id -> [p1, p2]
    @edges = {}
    @next_edge_id = 0

    # for each point, all the edges which connect to it
    @edges_of_point = Hash.new{[]}

    # length of each edge
    @length = {}

    # hash of triangle_id -> [edge1_id, edge2_id, edge3_id]
    @triangles = {}
    @next_triangle_id = 0

    # reverse of triangle table: edge_id -> [triangle1_id, ...]
    # in a non-overlapping 2D plane, a max of two triangles can use an edge
    @triangles_of_edge = Hash.new{[]}

    # triangles which have been created since we last iterated
    @new_triangles = []

  end

  def to_s
    "points = #{@points}\n" +
    "edges = #{@edges}\n" +
    "edges_of_point = #{@edges_of_point}\n" +
    "length = #{@length}\n" +
    "triangles = #{@triangles}\n" +
    "triangles_of_edge = #{@triangles_of_edge}\n" +
    "new_triangles = #{@new_triangles}\n"
  end

  def add_point(x, y)
    pid = @next_point_id += 1
    @points[pid] = [x, y]
    pid
  end

  def add_edge(p1, p2)
    eid = @next_edge_id += 1
    @edges[eid] = [p1, p2]
    x1, y1 = @points[p1]
    x2, y2 = @points[p2]
    @length[eid] = ((x1 - x2) ** 2 + (y1 - y2) ** 2) ** 0.5
    # reverse mapping: points to edges
    @edges_of_point[p1] += [eid]
    @edges_of_point[p2] += [eid]
    eid
  end

  def add_triangle(e1, e2, e3)
    tid = @next_triangle_id += 1
    # sort edges by length, shortest first
    @triangles[tid] = [e1, e2, e3].sort{|a, b| @length[a] - @length[b]}
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
    p1, p2 = @edges[eid]
    @edges[eid] = nil

    @edges_of_point[p1] -= [eid]
    @edges_of_point[p2] -= [eid]
  end

  # remove a triangle (but don't touch the edges that make up the triangle --
  # our caller must do that)
  def remove_triangle(tid)
    edges = @triangles[tid]
    @triangles[tid] = nil

    edges.each do |eid|
      raise "triangle not attached to edge" if ! @triangles_of_edge.include? tid
      @triangles_of_edge[eid] -= [tid]
    end
  end

  def acute?(tid)
    # stored shortest edge first
    e1, e2, e3 = @triangles[tid]

    # acute if a ** 2 + b ** 2 > c ** 2, where c is the longest edge
    @length[e1] ** 2 + @length[e2] ** 2 > @length[e3] ** 2
  end

  # split a triangle into three based on a point at the centre
  def divide(tid)
    # stored shortest edge first
    e1, e2, e3 = @triangles[tid]
    p1, p2 = @edges[e1]

    # swap e2/e3 if necessary so that e1 and e3 share p1
    p3, p4 = @edges[e3]
    if p3 != p1 && p4 != p2
      e2, e3 = e3, e2
    end

    # so the third point of the triangle is the one that's not p1 or p2
    if p3 == p1 || p3 == p2
      p3 = p4
    end

    x1, y1 = @points[p1]
    x2, y2 = @points[p2]
    x3, y3 = @points[p3]
    pc = add_point((x1 + x2 + x3) / 3, (y1 + y2 + y3) / 3)

    remove_triangle(tid)

    e4 = add_edge(pc, p1)
    e5 = add_edge(pc, p3)
    e6 = add_edge(pc, p2)

    add_triangle(e1, e4, e6)
    add_triangle(e2, e4, e5)
    add_triangle(e3, e6, e5)
  end

  # join a triangle to its neighbour along the longest edge, then bisect along
  # the major axis
  def join(tid)
    # stored shortest edge first
    e1, e2, e3 = @triangles[tid]

    # there sholuld be another triangle using the long edge
    tids = @triangles_of_edge[e3]
    raise "#{tids.length} tris on edge" if tids.length != 1 && tids.length != 2

    t2 = tids.filter{|x| x != tid}.first

    puts "joining #{tid} and #{t2}"
    puts "before join, mesh is:"
    puts self

    # we want the two edges that are not e3
    raise "edge not shared" if ! @triangles[t2].include?(e3)
    e4, e5 = @triangles[t2].filter{|x| x != e3}

    remove_triangle(tid)
    remove_triangle(t2)

    # swap e4/e5 if necessary so that e1 and e4 share a point
    p1, p2 = @edges[e1]
    p3, p4 = @edges[e2]
    p5, p6 = @edges[e5]
    if p5 == p1 || p5 == p2 || p6 == p1 || p6 == p2
      e4, e5 = e5, e4
    end

    # e1 and e2 must share a point, and that point will be the adjacent
    # vertex
    if p1 == p3
      adjacent = p1
    else
      adjacent = p2
    end

    # e4 and e5 must share a point, and that point will be the opposite
    # vertex
    p1, p2 = @edges[e4]
    p3, p4 = @edges[e5]
    if p1 == p3
      opposite = p1
    else
      opposite = p2
    end

    puts "e1 = #{e1}"
    puts "e2 = #{e2}"
    puts "e3 = #{e3}"
    puts "e4 = #{e4}"
    puts "e5 = #{e5}"
    puts "opposite = #{opposite}"
    puts "adjacent = #{adjacent}"

    remove_edge(e3)
    e6 = add_edge(adjacent, opposite)

    add_triangle(e1, e4, e6)
    add_triangle(e2, e5, e6)

    puts "after join, mesh is:"
    puts self

    exit
  end

  def iterate
    tids = @new_triangles
    @new_triangles = []

    tids.each do |tid|
      next if @triangles[tid].nil?

      # stored shortest edge first
      e1, e2, e3 = @triangles[tid]
      tids = @triangles_of_edge[e3]

      # if this tri has a longest edge that's not shared, we can't join
      if tids.length == 1 || acute?(tid)
        divide(tid)
      else
        join(tid)
      end
    end
  end

  def to_svg(filename)
    File.open filename, "w" do |file|
      Svg.new file, viewBox: "0 0 1024 707" do |svg|
        @edges.each do |eid, points|
          next if points.nil?

          p1, p2 = points
          svg.line @points[p1], @points[p2], 
            style: "stroke: black; stroke-width: 0.7"
        end
      end
    end
  end

end

mesh = Mesh.new
p1 = mesh.add_point(0, 0)
p2 = mesh.add_point(1024, 0)
p3 = mesh.add_point(512, 707)
e1 = mesh.add_edge(p1, p2)
e2 = mesh.add_edge(p2, p3)
e3 = mesh.add_edge(p3, p1)
t1 = mesh.add_triangle(e1, e2, e3)

3.times do |i|
  puts "generation #{i} ..."
  mesh.iterate
end

output = "mesh.svg"
puts "writing #{output} ..."
mesh.to_svg output

