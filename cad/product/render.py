# Ray-traced product shot of the bot in translucent PETG. Run through product/render.sh, which exports the meshes first.
#   render.py <meshes dir> <out.jpg> <shot> <width> <samples>
import bpy, bmesh, math, sys, os
from mathutils import Matrix

d, out, shot, res, samples = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), int(sys.argv[5])

# model dimensions, written by render.sh, in mm
HULL_H, WHEEL_D = [float(v) / 1000 for v in open(os.path.join(d, "dims.txt")).read().split(",")]
STAND = WHEEL_D / 2  # height of the axle line when the bot stands on its wheels
REST = HULL_H / 2    # and when a shell lies on its outer face

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = samples
scene.cycles.use_denoising = True
scene.cycles.max_bounces = 24
scene.cycles.transmission_bounces = 24
scene.cycles.transparent_max_bounces = 24
scene.render.resolution_x = res
scene.render.resolution_y = int(res * 0.75)
scene.render.filepath = out
scene.render.image_settings.file_format = "JPEG"
scene.render.image_settings.quality = 92
scene.view_settings.view_transform = "AgX"
scene.view_settings.look = "AgX - Medium High Contrast"


def plastic(name, color, rough, bevel=0.0002, metallic=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metallic
    if bevel:
        bev = nt.nodes.new("ShaderNodeBevel")
        bev.samples = 6
        bev.inputs["Radius"].default_value = bevel
        nt.links.new(bev.outputs["Normal"], b.inputs["Normal"])
    return m


def nodes_for(m):
    nt = m.node_tree
    N, L = nt.nodes, nt.links

    def mnode(op, a, b=None):
        n = N.new("ShaderNodeMath")
        n.operation = op
        for i, v in enumerate([a, b]):
            if v is None:
                continue
            if isinstance(v, (int, float)):
                n.inputs[i].default_value = v
            else:
                L.new(v, n.inputs[i])
        return n.outputs[0]

    def vnode(op, a, b=None):
        n = N.new("ShaderNodeVectorMath")
        n.operation = op
        for i, v in enumerate([a, b]):
            if v is None:
                continue
            if isinstance(v, tuple):
                n.inputs[i].default_value = v
            else:
                L.new(v, n.inputs[i])
        return n.outputs

    return N, L, mnode, vnode


# light passes straight through for shadow rays, so the inside and the floor underneath are lit
def see_through_shadows(m, shader, tint):
    N, L = m.node_tree.nodes, m.node_tree.links
    lp = N.new("ShaderNodeLightPath")
    tr = N.new("ShaderNodeBsdfTransparent")
    tr.inputs["Color"].default_value = (*tint, 1)
    mix = N.new("ShaderNodeMixShader")
    L.new(lp.outputs["Is Shadow Ray"], mix.inputs["Fac"])
    L.new(shader, mix.inputs[1])
    L.new(tr.outputs["BSDF"], mix.inputs[2])
    L.new(mix.outputs["Shader"], N["Material Output"].inputs["Surface"])


# printed translucent PETG: milky, layer lines up the walls (the shells print along their Z),
# the pebbled imprint of the build plate on the two outer faces
def translucent(name, color):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    N, L, mnode, vnode = nodes_for(m)
    b = N["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Roughness"].default_value = 0.13
    b.inputs["Transmission Weight"].default_value = 0.93
    b.inputs["IOR"].default_value = 1.57
    tc = N.new("ShaderNodeTexCoord")
    sep = N.new("ShaderNodeSeparateXYZ")
    L.new(tc.outputs["Object"], sep.inputs[0])
    geo = N.new("ShaderNodeNewGeometry")
    # object space normal, so it works for shells that were turned over or moved
    vt = N.new("ShaderNodeVectorTransform")
    vt.vector_type = "NORMAL"
    vt.convert_from = "WORLD"
    vt.convert_to = "OBJECT"
    L.new(geo.outputs["Normal"], vt.inputs[0])
    facing = mnode("POWER", mnode("ABSOLUTE", vnode("DOT_PRODUCT", vt.outputs[0], (0, 0, 1))["Value"]), 4)
    ripple = mnode("MULTIPLY", mnode("ABSOLUTE", mnode("SINE", mnode("MULTIPLY", sep.outputs["Z"], math.pi / 0.2))),
                   mnode("SUBTRACT", 1, facing))
    fine = N.new("ShaderNodeTexNoise")
    fine.inputs["Scale"].default_value = 2500
    pebble = mnode("MULTIPLY", mnode("MULTIPLY", fine.outputs["Fac"], 0.2), facing)
    bev = N.new("ShaderNodeBevel")
    bev.samples = 4
    bev.inputs["Radius"].default_value = 0.0003
    bp = N.new("ShaderNodeBump")
    bp.inputs["Strength"].default_value = 1.0
    bp.inputs["Distance"].default_value = 0.00012
    L.new(mnode("ADD", mnode("MULTIPLY", ripple, 0.35), pebble), bp.inputs["Height"])
    L.new(bev.outputs["Normal"], bp.inputs["Normal"])
    L.new(bp.outputs["Normal"], b.inputs["Normal"])
    see_through_shadows(m, b.outputs["BSDF"], [0.45 + 0.45 * c for c in color])
    return m


def emissive(name, color, strength):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (0, 0, 0, 1)
    b.inputs["Emission Color"].default_value = (*color, 1)
    b.inputs["Emission Strength"].default_value = strength
    return m


def load(name, mat, matrix):
    bpy.ops.wm.stl_import(filepath=os.path.join(d, name + ".stl"), global_scale=0.001)
    o = bpy.context.selected_objects[0]
    me = o.data
    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-6)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = True
    me.set_sharp_from_angle(angle=math.radians(35))
    me.materials.append(mat)
    o.matrix_world = matrix @ o.matrix_world  # the import leaves the mm to m scale on the object
    return o


def T(x, y, z):
    return Matrix.Translation((x, y, z))


def yaw(deg):
    return Matrix.Rotation(math.radians(deg), 4, "Z")


FLIP = Matrix.Rotation(math.radians(180), 4, "X")
CLEAR = (0.93, 0.96, 0.98)
WIRES = {
    "red": (0.55, 0.02, 0.015),
    "black": (0.006, 0.006, 0.006),
    "white": (0.82, 0.82, 0.78),
    "yellow": (0.80, 0.52, 0.01),
    "green": (0.02, 0.30, 0.06),
    "blue": (0.02, 0.13, 0.62),
}
CONTENTS = ["tyres", "steel", "brass", "pcb_dark", "pcb_blue", "pcb_purple", "chips", "white", "battery", "tape", "foam", "led"]
CONTENTS += ["wire_" + name for name in WIRES]
mat = {}


def materials():
    mat.update(
        base=translucent("base", CLEAR),
        lid=translucent("lid", CLEAR),
        tyres=plastic("tyres", (0.62, 0.035, 0.02), 0.6, bevel=0.0006),
        steel=plastic("steel", (0.60, 0.61, 0.63), 0.28, bevel=0.0001, metallic=1.0),
        brass=plastic("brass", (0.80, 0.58, 0.22), 0.3, bevel=0, metallic=1.0),
        pcb_dark=plastic("pcb_dark", (0.010, 0.022, 0.035), 0.4, bevel=0),
        pcb_blue=plastic("pcb_blue", (0.012, 0.07, 0.30), 0.4, bevel=0),
        pcb_purple=plastic("pcb_purple", (0.14, 0.02, 0.28), 0.4, bevel=0),
        chips=plastic("chips", (0.004, 0.004, 0.004), 0.5, bevel=0),
        white=plastic("white", (0.80, 0.78, 0.70), 0.5),
        battery=plastic("battery", (0.72, 0.74, 0.77), 0.38, bevel=0.0004, metallic=0.9),
        tape=plastic("tape", (0.72, 0.42, 0.03), 0.3, bevel=0),
        foam=plastic("foam", (0.02, 0.02, 0.022), 0.9, bevel=0),
        led=emissive("led", (0.10, 0.40, 1.0), 90),
    )
    for name, color in WIRES.items():
        mat["wire_" + name] = plastic("wire_" + name, color, 0.55, bevel=0)


# one bot: where the base, its contents and the lid go
def bot(base=Matrix.Identity(4), contents=None, lid=None):
    load("base", mat["base"], base)
    for name in CONTENTS:
        load(name, mat[name], base if contents is None else contents)
    load("lid", mat["lid"], base if lid is None else lid)


materials()
SHOTS = {
    # name: (camera, target, lens, f-stop or None)
    "hero": ((-0.20, 0.40, 0.19), (0.0, 0.0, 0.012), 85, None),
    "pair": ((0.0, 0.62, 0.34), (0.0, 0.0, 0.012), 70, None),
    "exploded": ((-0.27, 0.52, 0.28), (0.0, 0.0, 0.040), 92, None),
    "open": ((0.0, 0.62, 0.33), (0.0, 0.0, 0.006), 70, None),
    "detail": ((0.10, 0.27, 0.075), (0.028, 0.053, 0.010), 68, None),
}
cam_loc, cam_at, lens, fstop = SHOTS[shot]

stand = T(0, 0, STAND)
if shot == "pair":
    # the same bot twice: on its wheels, and on its back
    bot(T(-0.084, 0, STAND) @ yaw(-20))
    bot(T(0.084, 0, STAND) @ yaw(20) @ FLIP)
elif shot == "exploded":
    turn = yaw(-28)
    bot(stand @ turn, contents=T(0, 0, STAND + 0.024) @ turn, lid=T(0, 0, STAND + 0.058) @ turn)
elif shot == "open":
    # lid off and turned over beside the base, so its fingers and keepers show
    bot(T(-0.072, 0, STAND) @ yaw(-12), lid=T(0.072, 0, REST) @ yaw(12) @ FLIP)
else:
    bot(stand @ yaw(-28))

# seamless backdrop: floor that curves up into a wall behind the bot
bg = 0.06
prof = [(2.5, 0.0), (-0.45, 0.0)]
r = 0.35
for i in range(1, 17):
    a = math.radians(90 * i / 16)
    prof.append((-0.45 - r * math.sin(a), r - r * math.cos(a)))
prof.append((-0.45 - r, 2.5))
verts = [(x, y, z) for (y, z) in prof for x in (-4, 4)]
faces = [(2 * i, 2 * i + 1, 2 * i + 3, 2 * i + 2) for i in range(len(prof) - 1)]
me = bpy.data.meshes.new("backdrop")
me.from_pydata(verts, [], faces)
for p in me.polygons:
    p.use_smooth = True
back = bpy.data.objects.new("backdrop", me)
scene.collection.objects.link(back)
me.materials.append(plastic("backdrop", (bg, bg * 1.03, bg * 1.1), 0.7, bevel=0))

world = bpy.data.worlds.new("w")
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (1, 1, 1, 1)
world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.04
scene.world = world


def empty(name, loc):
    o = bpy.data.objects.new(name, None)
    o.location = loc
    scene.collection.objects.link(o)
    return o


centre = empty("centre", (0, 0, 0.012))
look = empty("look", cam_at)


def aim(o, at):
    c = o.constraints.new("TRACK_TO")
    c.target = at
    c.track_axis = "TRACK_NEGATIVE_Z"
    c.up_axis = "UP_Y"


def area(name, loc, size, power, color=(1, 1, 1)):
    l = bpy.data.lights.new(name, "AREA")
    l.shape = "RECTANGLE"
    l.size, l.size_y = size
    l.energy = power * 0.42
    l.color = color
    o = bpy.data.objects.new(name, l)
    o.location = loc
    scene.collection.objects.link(o)
    aim(o, centre)


area("key", (0.45, 0.50, 0.55), (0.5, 0.5), 16, (1.0, 0.97, 0.93))
area("fill", (-0.6, 0.40, 0.2), (0.6, 0.6), 3, (0.9, 0.95, 1.0))
area("rim", (-0.25, -0.6, 0.5), (0.5, 0.3), 14)
area("top", (0.0, 0.05, 0.7), (0.7, 0.7), 5)

cam = bpy.data.cameras.new("cam")
cam.lens = lens
cam.sensor_width = 36
if fstop:
    cam.dof.use_dof = True
    cam.dof.focus_object = look
    cam.dof.aperture_fstop = fstop
co = bpy.data.objects.new("cam", cam)
co.location = cam_loc
scene.collection.objects.link(co)
aim(co, look)
scene.camera = co

bpy.ops.render.render(write_still=True)
