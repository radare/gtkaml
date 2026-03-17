project(
  'gtkaml',
  ['c', 'vala'],
  version: '0.6.0',
  meson_version: '>= 1.0.0',
)

vala = meson.get_compiler('vala')
if not vala.version().version_compare('>=0.48')
  error('gtkaml requires valac >= 0.48')
endif

vala_versions = [
  '0.64',
  '0.62',
  '0.60',
  '0.58',
  '0.56',
  '0.54',
  '0.52',
  '0.50',
  '0.48',
  '0.46',
  '0.44',
  '0.42',
  '0.40',
  '0.38',
  '0.36',
  '0.34',
  '0.32',
  '0.30',
  '0.28',
  '0.26',
  '0.24',
  '0.22',
  '0.20',
  '0.18',
  '0.16',
]

vala_pkg_name = ''
vala_version = ''
vala_dep = disabler()
foreach candidate : vala_versions
  dep = dependency('libvala-' + candidate, required: false)
  if dep.found()
    vala_pkg_name = 'libvala-' + candidate
    vala_version = candidate
    vala_dep = dep
    break
  endif
endforeach

if vala_pkg_name == ''
  error('libvala development files were not found. Install a matching libvala-*.pc package for your valac toolchain.')
endif

glib_dep = dependency('glib-2.0', version: '>=2.48')
gio_dep = dependency('gio-2.0', version: '>=2.48')
libxml2_dep = dependency('libxml-2.0')

gtk3_dep = dependency('gtk+-3.0', required: false)
gtk4_dep = dependency('gtk4', required: false)
adwaita_dep = dependency('libadwaita-1', required: false)

gtk_api = get_option('gtk_api')
build_gtk3_targets = false
build_gtk4_targets = false
build_adwaita_targets = false

if gtk_api == 'auto'
  build_gtk3_targets = gtk3_dep.found()
  build_gtk4_targets = gtk4_dep.found()
  build_adwaita_targets = adwaita_dep.found()
elif gtk_api == 'gtk3'
  if not gtk3_dep.found()
    error('gtk_api=gtk3 requires gtk+-3.0 to be installed')
  endif
  build_gtk3_targets = true
elif gtk_api == 'gtk4'
  if not gtk4_dep.found()
    error('gtk_api=gtk4 requires gtk4 to be installed')
  endif
  build_gtk4_targets = true
elif gtk_api == 'adwaita'
  if not gtk4_dep.found() or not adwaita_dep.found()
    error('gtk_api=adwaita requires both gtk4 and libadwaita-1 to be installed')
  endif
  build_adwaita_targets = true
endif

vala_codegen_libdir = vala_dep.get_variable(pkgconfig: 'libdir') / ('vala-' + vala_version)
vala_internal_vapi_dir = join_paths(
  vala_dep.get_variable(pkgconfig: 'prefix'),
  'share',
  'vala',
  'vapi',
)
valadoc = find_program('valadoc', required: get_option('docs'))
gtkaml_to_vala = find_program('tools/gtkaml-to-vala.sh')

config_data = configuration_data()
config_data.set_quoted('PACKAGE_VERSION', meson.project_version())
config_data.set_quoted('PACKAGE_DATADIR', join_paths(get_option('datadir'), meson.project_name()))
config_data.set_quoted('VALA_VERSION', vala_version)

config_h = configure_file(
  output: 'config.h',
  configuration: config_data,
)

gtkaml_deps_file = configure_file(
  input: 'libgtkaml/gtkaml-1.0.deps.in',
  output: 'gtkaml-1.0.deps',
  configuration: config_data,
)

root_inc = include_directories('.')
vapi_inc = include_directories('vapi')
libgtkaml_inc = include_directories('libgtkaml')

config_vapi = files('vapi/config.vapi')
valaccodegen_vapi = files('vapi/valaccodegen.vapi')

common_deps = [
  glib_dep,
  gio_dep,
  libxml2_dep,
  vala_dep,
]

pkg = import('pkgconfig')

subdir('libgtkaml')
subdir('src')
subdir('data')
subdir('markuphints')

if get_option('examples')
  subdir('examples')
endif

if get_option('tests')
  subdir('tests')
endif

install_man('gtkamlc.1')

summary({
  'libvala package': vala_pkg_name,
  'libvalaccodegen dir': vala_codegen_libdir,
  'selected GTK API': gtk_api,
  'GTK+ 3 tests': gtk3_dep.found(),
  'GTK 4 tests': gtk4_dep.found(),
  'libadwaita tests': adwaita_dep.found(),
  'build examples': get_option('examples'),
  'build smoke tests': get_option('tests'),
  'build docs target': get_option('docs'),
}, section: 'gtkaml')
