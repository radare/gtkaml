foreach example_name : [
  'gtk-hello',
  'search-dialog',
  'sync-sample',
  'treeview-liststore-sample',
]
  custom_target(
    'example-gtkon-' + example_name,
    input: example_name + '.gtkon',
    output: example_name,
    command: [
      gtkamlc,
      '--pkg',
      'gtk+-3.0',
    ] + gtkamlc_markup_args + [
      '-o',
      '@OUTPUT@',
      '@INPUT@',
    ],
    build_by_default: true,
  )
endforeach
