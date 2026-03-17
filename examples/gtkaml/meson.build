foreach example_name : [
  'gtk-hello',
  'search-dialog',
  'sync-sample',
  'treeview-liststore-sample',
]
  custom_target(
    'example-gtkaml-' + example_name,
    input: example_name + '.gtkaml',
    output: example_name + '.vala',
    command: [
      gtkaml_to_vala,
      gtkamlc,
      '@INPUT@',
      '@OUTPUT@',
      '--pkg',
      'gtk+-3.0',
      '--vapidir',
      meson.project_source_root() / 'markuphints',
      '--implicitsdir',
      meson.project_source_root() / 'data',
    ],
    build_by_default: true,
  )
endforeach
