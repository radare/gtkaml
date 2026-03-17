gtkaml_library_sources = files(
  'gtkamlcodecontext.vala',
  'gtkamlmarkupparser.vala',
  'gtkonparser.vala',
  'gtkamlmarkupscanner.vala',
  'gtkamlmarkupresolver.vala',
  'gtkamlcodeparserprovider.vala',
  'ast/gtkamlmarkupattribute.vala',
  'ast/gtkamlmarkupcomplexattribute.vala',
  'gtkamlmarkupclass.vala',
  'ast/gtkamlmarkuptag.vala',
  'ast/gtkamlmarkuproot.vala',
  'ast/gtkamlmarkupchildtag.vala',
  'ast/gtkamlmarkupunresolvedtag.vala',
  'ast/gtkamlmarkupmember.vala',
  'ast/gtkamlmarkuptemp.vala',
  'ast/gtkamlmarkupreference.vala',
  'gtkamlmarkupnamespace.vala',
  'gtkamlmarkuphint.vala',
  'gtkamlmarkuphintsstore.vala',
  'gtkamlpropertyspec.vala',
  'workarounds/gtkamldatatypeparent.vala',
  'workarounds/gtkamlcallable.vala',
  'workarounds/gtkamlvalaparser.vala',
  'workarounds/gtkamlnamespacevisitor.vala',
)

gtkaml_lib = library(
  'gtkaml',
  [config_vapi] + gtkaml_library_sources,
  dependencies: common_deps,
  include_directories: [
    root_inc,
    libgtkaml_inc,
  ],
  vala_args: [
    '--vapidir=' + vala_internal_vapi_dir,
  ],
  vala_header: 'gtkaml.h',
  vala_vapi: 'gtkaml-1.0.vapi',
  install: true,
  install_dir: [
    get_option('libdir'),
    join_paths(get_option('includedir'), 'gtkaml-1.0'),
    join_paths(get_option('datadir'), 'vala', 'vapi'),
  ],
)

gtkaml_dep = declare_dependency(
  link_with: gtkaml_lib,
  include_directories: [
    root_inc,
    libgtkaml_inc,
  ],
)

install_data(
  gtkaml_deps_file,
  install_dir: join_paths(get_option('datadir'), 'vala', 'vapi'),
)

pkg.generate(
  gtkaml_lib,
  filebase: 'gtkaml-1.0',
  name: 'Gtkaml',
  description: 'The Gtkaml markup parser',
  subdirs: 'gtkaml-1.0',
  requires: [
    'glib-2.0',
    'gio-2.0',
    'libxml-2.0',
    vala_pkg_name,
  ],
  version: meson.project_version(),
)

if get_option('docs')
  run_target(
    'valadoc',
    command: [
      valadoc,
      '-o',
      join_paths(meson.project_build_root(), 'valadoc'),
      '-b',
      meson.project_source_root(),
      '--vapidir',
      meson.project_source_root() / 'vapi',
      '--vapidir',
      vala_internal_vapi_dir,
      '--pkg',
      vala_pkg_name,
      '--pkg',
      'config',
      '--pkg',
      'gio-2.0',
      '--pkg',
      'libxml-2.0',
      '--force',
      '--package-name=Gtkaml',
      '--package-version=' + meson.project_version(),
    ] + gtkaml_library_sources,
  )
endif
