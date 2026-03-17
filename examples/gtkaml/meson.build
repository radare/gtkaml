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
      gtkamlc,
      '--pkg',
      'gtk+-3.0',
    ] + gtkamlc_markup_args + [
      '-V',
      '@INPUT@',
    ],
    build_by_default: true,
  )
endforeach
